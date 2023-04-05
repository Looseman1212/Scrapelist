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
    # getting the url created
    url_page_one = @scrapelist.bandcamp_query
    url_page_two = @scrapelist.query_two
    scrape_bandcamp(url_page_one) # two functions for scraping
    scrape_bandcamp(url_page_two)
    # create an instance variable where we can access the songs
    @songs = Song.where(scrapelistprompt_id: @scrapelist.id)
  end

  def choose
    # Extract the authorization code from the query parameters
    authorization_code = params[:code]
    # set the access token for the session with this function
    setAccessTokenForSession(authorization_code)
    # set the user account details for the session with this function
    grabUserAccountDetails(session[:access_token])
  end

  def new_easy
    @scrapelist = Scrapelistprompt.new
  end

  def create_easy
    @scrapelist = Scrapelistprompt.new(scrapelist_params_easy)
    @scrapelist.subgenre = ''
    @scrapelist.release_order = 'new'
    @scrapelist.page_number = 0
    @scrapelist.location = 0
    @scrapelist.time_frame = 0
    @scrapelist.spotify_account = 'TODO'
    @scrapelist.bandcamp_query = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    @scrapelist.query_two = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 1}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    @scrapelist.query_three = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 2}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    @scrapelist.query_four = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 3}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    @scrapelist.query_five = "https://bandcamp.com/?g=#{@scrapelist.genre}&s=#{@scrapelist.release_order}&p=#{@scrapelist.page_number + 4}&gn=#{@scrapelist.location}&f=all&w=#{@scrapelist.time_frame}"
    if @scrapelist.save!
      redirect_to one_scrapelist_path(@scrapelist)
    else
      render :new_easy, status: :unprocessable_entity
    end
  end

  def new_picky; end

  def create_picky; end

  def send_to_spotify
    @scrapelist = Scrapelistprompt.find(params[:id])
    # create an instance variable to store the songs in the scrapelist, and an array to store the spotify ids found
    @songs = Song.where(scrapelistprompt_id: params[:id])
    spotify_uris = grabSongURIs(@songs)
    createSpotifyPlaylist(spotify_uris, @scrapelist.genre)
  end

  private

  def scrapelist_params_easy
    params.require(:scrapelistprompt).permit(:genre) # think about do I need to add spotify account here? Is it a necessary part of the schema?
  end

  def scrapelist_params_picky
    params.require(:scrapelistprompt).permit(:spotify_account, :genre, :subgenre, :release_order, :time_frame, :location)
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

  def setAccessTokenForSession(auth_code)
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

  def grabUserAccountDetails(access_token)
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

  def grabSongURIs(songs)
    # array for storing the spotify URI's
    spotify_uris = []

    # spotify_artists = [] # this line is for debugging purposes

    # search for each song in the scrapelist on spotify
    @songs.each do |song|
      # Set the search parameters
      query = {
        q: "track:#{song.title} album:#{song.album} artist:#{song.artist}",
        type: 'track'
      }
      # Set the request headers, including the access token
      headers = {
        "Authorization" => "Bearer #{session[:access_token]}",
        "Content-Type" => "application/json"
      }
      # make the request
      response = HTTParty.get("https://api.spotify.com/v1/search", query: query, headers: headers)
      # Parse the response body as JSON and extract the search results
      results = JSON.parse(response.body)["tracks"]["items"]
      # save the URI from the first result to the array if it isnt null
      spotify_uris << results[0]["uri"] unless results[0].nil?

      # spotify_artists << results[0]["artists"][0]["name"] unless results[0].nil? # this line is for debugging purposes

    end
    spotify_uris

    # spotify_artists # this line is for debugging purposes
  end

  def createSpotifyPlaylist(uris, scrapelist_genre)
    access_token = session[:access_token]
    user_id = session[:user_details]["id"]
    endpoint = "https://api.spotify.com/v1/users/#{user_id}/playlists"

    # Set up the request headers
    headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json'
    }

    # create and format a time for the playlist name
    time = Time.now
    formatted_time = time.strftime('%A %B %d%<suffix>s %Y')
    formatted_time.sub!(/\d{2}(st|nd|rd|th)/, '\1')

    # Set up the request body
    body = {
      name: "#{scrapelist_genre} Scrapelist made #{formatted_time}",
      description: "A new playlist made with Scrapelist!",
      public: false
    }.to_json

    response = HTTParty.post(
      "https://api.spotify.com/v1/users/#{user_id}/playlists",
      headers: headers,
      body: body
    )


    # if statement to catch failure
    if response.code == 201
      playlist_id = response.parsed_response['id']
      raise
      return playlist_id
    else
      return response.message
    end
  end
end
