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

    # Make a request to the Spotify API token endpoint to exchange the authorization code for an access token
    response = HTTParty.post("https://accounts.spotify.com/api/token", {
      headers: {
        "Authorization" => "Basic #{Base64.strict_encode64("#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}")}",
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: {
        grant_type: "authorization_code",
        code: authorization_code,
        redirect_uri: 'http://127.0.0.1:3000/scrapelist/choice_page'
      }
    })

    # Extract the access token from the response
    access_token = response['access_token']

    # Save the access token to the session
    session[:access_token] = access_token # need to research this session term for rails
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
      song[:artist] = artist
      song[:album_art] = art
      song[:music_link] = link
      song[:scrapelistprompt_id] = @scrapelist.id
      song.save!
    end
    # close the browser after making all song instances in the database
    browser.close
  end
end
