require 'httparty'

class ScrapelistpromptsController < ApplicationController

  def index
    @scrapelists = Scrapelistprompt.all
  end

  def show
    @scrapelist = Scrapelistprompt.find(params[:id])
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
    if @scrapelist.save!
      redirect_to one_scrapelist_path(@scrapelist)
    else
      render :new_easy, status: :unprocessable_entity
    end
  end

  def index
    @scrapelists = Scrapelistprompt.all
  end

  private

  def scrapelist_params_easy
    params.require(:scrapelistprompt).permit(:genre) # think about do I need to add spotify account here? Is it a necessary part of the schema?
  end

  def scrapelist_params_picky
    params.require(:scrapelistprompt).permit(:spotify_account, :genre, :subgenre, :release_order, :time_frame, :location)
  end
end
