require 'httparty'
require 'watir'
require 'nokogiri'

class ScrapelistpromptsController < ApplicationController
  def index
    @scrapelists = Scrapelistprompt.all
  end

  def show # if the scraping isn't happening, lines 17 and 18 may be commented out!
    # finding the scrapelistprompt by id
    @scrapelist = Scrapelistprompt.find(params[:id])
    # create an instance variable where we can access the songs
    @songs = Song.where(scrapelistprompt_id: @scrapelist.id)
    # setting an instance variable for the view
    @heres_what_we_got = (@scrapelist.subgenre == 'all' ? @scrapelist.genre : @scrapelist.subgenre)
    # only scrape if there are no songs in the database
    return unless @songs.empty?

    scrape_bandcamp(@scrapelist.bandcamp_query) # two functions for scraping
    scrape_bandcamp(@scrapelist.query_two)
    redirect_to error_no_scrape_path if @songs.empty?
  end

  def show_test
    @scrapelist = Scrapelistprompt.find(params[:id])
  end

  def choose
    # Extract the authorization code from the query parameters
    authorization_code = params[:code]
    # set the access token for the session with this function using the authorization code
    set_access_token_for_session(authorization_code)
    # set the user account details for the session with this function
    grab_user_account_details(session[:access_token])
  end

  def new_easy
    @scrapelist = Scrapelistprompt.new
  end

  def create_easy
    @scrapelist = Scrapelistprompt.new(scrapelist_params_easy)
    @scrapelist.subgenre = 'all'
    @scrapelist.release_order = 'top'
    @scrapelist.page_number = 0
    @scrapelist.location = 0
    @scrapelist.time_frame = 0
    @scrapelist.bandcamp_query = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    @scrapelist.query_two = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 1}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    # @scrapelist.query_three = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 2}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    # @scrapelist.query_four = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 3}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    # @scrapelist.query_five = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 4}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    if @scrapelist.save!
      redirect_to one_scrapelist_path(@scrapelist)
    else
      # render :new_easy, status: :unprocessable_entity
      redirect_to error_general_path
    end
  end

  def new_picky
    @scrapelist = Scrapelistprompt.new
  end

  def create_picky
    # create new scrapelist object
    @scrapelist = Scrapelistprompt.new(scrapelist_params_picky)
    @scrapelist.page_number = 0
    # handle scrapelist subgenre if genre is all
    @scrapelist.subgenre = (@scrapelist.genre == 'all' ? 'all~all' : @scrapelist.subgenre)

    # regex for getting the subgenre from the radio buttons value /#{radio_button.value}~(.+)/
    subgenre_regex = @scrapelist.subgenre.match(/.+~(.+)/)
    @scrapelist.subgenre = subgenre_regex[1]

    # only include the time frame if the subgenre is all
    if @scrapelist.subgenre == 'all' # && @scrapelist.location.zero?
      @scrapelist.bandcamp_query = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
      @scrapelist.query_two = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 1}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    else
      @scrapelist.bandcamp_query = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number}&gn=#{@scrapelist.location}&f=all&t=#{@scrapelist.subgenre}"
      @scrapelist.query_two = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 1}&gn=#{@scrapelist.location}&f=all&t=#{@scrapelist.subgenre}"
    end

    # redirect to the scrapelist view page if the scrapelist is saved
    if @scrapelist.save!
      # redirect_to one_scrapelist_test_path(@scrapelist)
      redirect_to one_scrapelist_path(@scrapelist)
    else
      # render :new_picky, status: :unprocessable_entity
      redirect_to error_general_path
    end
  end

  def send_to_spotify
    # create instance variables to store the current scrapelist and the songs which are in it
    @scrapelist = Scrapelistprompt.find(params[:id])
    @songs = Song.where(scrapelistprompt_id: params[:id])
    # array of songs found with spotify search
    spotify_uris = grab_song_URIs(@songs)
    # if statement to throw error if no songs are found
    redirect_to error_no_songs_path and return if spotify_uris.empty?

    # create a new playlist, then populate it with the songs
    new_playlist = create_spotify_playlist(@scrapelist)
    populate_playlist_response_code = populate_new_playlist(new_playlist[:playlist_id], spotify_uris)
    # create instance variable to pass to the view
    @playlist_link = new_playlist[:external_url]
    # unless statement to catch failure
    redirect_to error_general_path unless populate_playlist_response_code == 201
  end

  private

  def scrapelist_params_easy
    params.require(:scrapelistprompt).permit(:genre) # think about do I need to add spotify account here? Is it a necessary part of the schema?
  end

  def scrapelist_params_picky
    params.require(:scrapelistprompt).permit(:genre, :subgenre, :release_order, :time_frame, :location)
  end

  def scrape_bandcamp(link)
    # creating a new browser and passing it the url
    browser = Watir::Browser.new
    browser.goto(link)
    # grabbing a group of links to songs from the page
    links = browser.links(class: 'item-link')
    # iterating over each link and clicking it
    links.each do |l|
      l.click
      # create a Nokogiri object after clicking
      html_doc = Nokogiri::HTML(browser.html)
      # grab song details from the page
      artist = html_doc.at_css('.detail-artist').content.match(/by\s(.+)/)[1]
      album = html_doc.at_css('.detail-album').content
      title = html_doc.at_css('.title').content
      art = html_doc.at_css('.detail-art').attribute('href')
      link = html_doc.at_css('.detail-album').children.attribute('href')
      # create a song object and save it to the database
      song = Song.new
      song[:title] = title
      song[:album] = album
      song[:album_art] = art
      song[:music_link] = link
      song[:artist] = artist
      song[:scrapelistprompt_id] = @scrapelist.id
      song.save!
    end
    # close the browser after making all song instances in the database
    browser.close
  end

  def set_access_token_for_session(auth_code)
    # Make a request to the Spotify API token endpoint to exchange the authorization code for an access token
    response = HTTParty.post("https://accounts.spotify.com/api/token", {
      headers: {
        "Authorization" => "Basic #{Base64.strict_encode64("#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}")}",
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: {
        grant_type: "authorization_code",
        code: auth_code,
        redirect_uri: 'http://127.0.0.1:3000/scrapelist/choice_page'
      }
    })
    # set the access token to session variable
    session[:access_token] = response['access_token']
  end

  def grab_user_account_details(access_token)
    # Set up the HTTParty request with the access token in the authorization header
    response = HTTParty.get("https://api.spotify.com/v1/me", headers: { "Authorization" => "Bearer #{access_token}" })

    # Extract the user's details from the response body
    user_details = JSON.parse(response.body)

    # # Extract the user's display name and email from the details
    # display_name = user_details["display_name"]
    # email = user_details["email"]

    # Set the user's details in the session
    session[:user_details] = user_details
  end

  def grab_song_URIs(songs)
    # array for storing the spotify URI's
    spotify_uris = []

    # search for each song in the scrapelist on spotify
    songs.each do |song|
      # regex to separate collaborating artists if there are any (which is represented by 'x', 'X', or '/' between artist names)
      # if there are not, then the whole artist will be returned as the first element in artist_array
      artist_names = song.artist
      artist_regex = /(?:\s+x\s+|\s+\/\s+|\s+X\s+)/
      artist_array = artist_names.split(artist_regex).map(&:strip)

      # Set the search parameters
      query = {
        q: "artist:#{artist_array[0]} track:#{song.title}", # only searching with artist and track has been returning better results
        type: 'track'
      }

      # Set the request headers, including the access token
      headers = {
        'Authorization' => "Bearer #{session[:access_token]}",
        'Content-Type' => 'application/json'
      }

      # make the request
      response = HTTParty.get('https://api.spotify.com/v1/search', query: query, headers: headers)
      # if the response includes the string error, then redirect to general error page
      if response.body.include?('error')
        redirect_to error_general_path
      else
        # Parse the response body as JSON and extract the search results
        results = JSON.parse(response.body)["tracks"]["items"]
        # save the URI from the first result to the array if it isnt null
        spotify_uris << results[0]['uri'] unless results[0].nil?
      end
    end
    spotify_uris
  end

  def create_spotify_playlist(scrapelist) # genre, subgenre, release_order, location
    access_token = session[:access_token]
    user_id = session[:user_details]["id"]
    endpoint = "https://api.spotify.com/v1/users/#{user_id}/playlists"

    # Set up request headers
    headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json'
    }

    # create and format a time and location for the playlist
    time = Time.now
    formatted_time = time.strftime('%A %B %d %Y')
    playlist_location = location_integer_tostring(scrapelist.location)

    # If statement to set up request body with or without subgenre
    if scrapelist.subgenre == 'all'
      body = {
        name: "#{scrapelist.genre.capitalize} Scrapelist made #{formatted_time}",
        description: "#{scrapelist.release_order.capitalize} releases from #{playlist_location}, made with Scrapelist!",
        public: false
      }.to_json
    else
      body = {
        name: "#{scrapelist.subgenre.capitalize} Scrapelist made #{formatted_time}",
        description: "#{scrapelist.release_order.capitalize} releases from #{playlist_location}, made with Scrapelist!",
        public: false
      }.to_json
    end

    # send post request
    response = HTTParty.post(
      endpoint,
      headers: headers,
      body: body
    )

    playlist_id = response.parsed_response['id']
    external_url = response.parsed_response['external_urls']['spotify']
    { playlist_id:, external_url: }
  end

  def populate_new_playlist(playlist, songs)
    access_token = session[:access_token]
    endpoint = "https://api.spotify.com/v1/playlists/#{playlist}/tracks"

    # set up request headers
    headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json'
    }

    # set up request body
    body = {
      uris: songs
    }.to_json

    # send post request
    response = HTTParty.post(
      endpoint, headers:, body:
    )

    response.code
  end

  def location_integer_tostring(integer)
    locations = {
      'EVERYWHERE': 0,
      'AMSTERDAM': 2759794,
      'ATLANTA': 4180439,
      'AUSTIN': 4671654,
      'BALTIMORE': 4347778,
      'BERLIN': 2950159,
      'BOSTON': 4930956,
      'BROOKLYN': 5110302,
      'CHICAGO': 4887398,
      'DENVER': 5419384,
      'DETROIT': 4990729,
      'DUBLIN': 2964574,
      'GLASGOW': 3333231,
      'LONDON': 2643743,
      'LOS ANGELES': 5368361,
      'MADRID': 3117735,
      'MANCHESTER': 2643123,
      'MELBOURNE': 2158177,
      'MEXICO CITY': 3530597,
      'MIAMI': 4164138,
      'MINNEAPOLIS': 5037649,
      'MONTREAL': 6077243,
      'NASHVILLE': 4644585,
      'NEW ORLEANS': 4335045,
      'NEW YORK CITY': 5128581,
      'OAKLAND': 5378538,
      'PARIS': 2988507,
      'PHILADELPHIA': 4560349,
      'PORTLAND': 5746545,
      'SAN FRANCISCO': 5391959,
      'SEATTLE': 5809844,
      'SYDNEY': 2147714,
      'TORONTO': 6167865,
      'VANCOUVER': 6173331,
      'WASHINGTON DC': 4140963
    }
    place_symbol = locations.key(integer)
    place_symbol == :EVERYWHERE ? place_symbol.to_s.downcase : place_symbol.to_s.downcase.capitalize
  end
end
