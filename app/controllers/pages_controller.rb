class PagesController < ApplicationController
  def home; end

  def login
    authorise = 'https://accounts.spotify.com/authorize'
    clientID = '3f15114ecf52461a95ef44a6b24976d7'
    url = authorise
    url += "?client_id=#{clientID}"
    url += '&response_type=code'
    url += '&redirect_uri=http://127.0.0.1:3000/scrapelists'
    url += '&show_dialog=true'
    url += '&scope=playlist-read-private'
    redirect_to url, allow_other_host: true
  end
end
