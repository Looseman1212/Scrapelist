# Scrapelist!

## A Ruby on Rails web app to discover new music from Bandcamp, and have it delivered directly to your Spotify account.
This project is a way for me to solve the problem I've had of how to discover new music from current artists conveniently, and on my own terms. I built this as a testament to the progress i've made learning about the Ruby on Rails stack. It solves the problem of wanting to find currently active underground artists, and then have them ready for you to listen on Spotify, which as a major platform usually only shows you new artists that already have bigger streaming numbers.

https://scrapelist-web-app.herokuapp.com/

## See a demo of the app in action <a href="https://www.youtube.com/watch?v=RLuMJm2zTOE" target="_blank">here</a>

## What I learned building this app
I learnt a lot about what it takes to manage building a full stack project solo. Getting my SQL database just right and practising my version tracking with git, making a web app can involve a lot of interconnecting parts, and steps which may seem small in the beginning, but then turn into more than what initially met the eye. I also am very happy with how much practise I got with scraping data from existing websites using Watir and Nokogiri, learning how to make efficient and effective server side HTTP requests, and reading Spotify's API documentation in order to learn how to use some of the features that their API has.

## If you would like to use the app
To use the website, I first need to add your Spotify account to my API endpoints user management. Send an email to maxwilliamreid@gmail.com with your full name and the email with which you made your Spotify account, then I can add your details and get back to you so you can start discovering music! The way to use it is pretty simple, once you authenticate your Spotify account, then you can choose the easy path or the picky path to making a Scrapelist. The easy path will have you just pick one genre, while the picky path will let you pick the genre, a subgenre, whether the releases are new arrivals or recent best sellers, and a time frame as well. Then you will see the results from Bandcamp, and you can explore these options, and can choose whether to have a playlist made on your Spotify.

## Known errors
The two errors you are most likely to encounter are:
1. Returning no results from searching Spotify
2. Returning no results from scraping Bandcamp

The solution to both of these is trying again and refining your search to be a bit more vague, in the hopes that more results that will work will pop up!

If you encounter any other problems please do not hesitate to email me :)

## If you're a dev and would like to contribute
If you are interested in contributing please let me know so I can add you to the API! Trust me when I say it will make debugging your additions a lot easier. Obviously when you get the project, you need to do the standard rails db:create db:migrate and then bundle install all the gems within the project. The Ruby version used is 3.1.2, Rails version is 7.0.4. When you contact me we can discuss more about how to manage pull requests and stuff like that.
