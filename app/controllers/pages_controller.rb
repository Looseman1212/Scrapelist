class PagesController < ApplicationController
  def home; end

  def login
    authorise = 'https://accounts.spotify.com/authorize'
    clientID = ENV['SPOTIFY_CLIENT_ID']
    url = authorise
    url += "?client_id=#{clientID}"
    url += '&response_type=code'
    url += '&redirect_uri=https://scrapelist-web-app.herokuapp.com/scrapelist/choice_page'
    # url += '&redirect_uri=http://127.0.0.1:3000/scrapelist/choice_page' # for local testing
    url += '&show_dialog=true'
    url += '&scope=playlist-modify-public playlist-modify-private user-read-email user-read-private'
    redirect_to url, allow_other_host: true
  end

  def error_no_songs; end

  def error_general; end

  def error_no_scrape; end
end
