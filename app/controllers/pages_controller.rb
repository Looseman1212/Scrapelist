class PagesController < ApplicationController
  def home; end

  def login
    authorise = 'https://accounts.spotify.com/authorize'
    clientID = ENV['SPOTIFY_CLIENT_ID']
    url = authorise
    url += "?client_id=#{clientID}"
    url += '&response_type=code'
    url += '&redirect_uri=http://127.0.0.1:3000/scrapelist/choice_page'
    url += '&show_dialog=true'
    url += '&scope=playlist-modify-private'
    redirect_to url, allow_other_host: true
  end
end
