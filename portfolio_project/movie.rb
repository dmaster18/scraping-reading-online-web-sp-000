require 'nokogiri'
require 'open-uri'
require 'pry'

class Scraper
  
  #Methods that interface with the IMDb HTML
  
  def self.index_page #Retrieves Nokogiri data from IMDb Index Page
    index_html = open("https://www.imdb.com/list/ls055592025/")
    Nokogiri::HTML(index_html)
  end
  
  def self.movie_page_url(input) #Generates selected movie's IMDb page HTML
	  resource = self.class.index_page.css(".lister-item-header a")[input - 1]["href"]
	  movie_page_url = "https://www.imdb.com" + resource
  end
  
  def self.movie_page #Retrieves Nokogiri data from selected movie's IMDb page
    movie_html = open(movie_page_url)
    Nokogiri::HTML(movie_html)
  end
  
  #Prints an array of top 100 movies from IMDb Index Page
	
	def self.print_movie_list #Prints an array of top 100 movies from IMDb Index Page
	  all_titles = []
	  i = 1
	  self.index_page.css("h3.lister-item-header a").each {|title| 
	    all_titles << "#{i}. #{title.text.strip}"
	    i+=1
	  }
	  puts all_titles
	end
  
	#Methods that detail with user's movie selection 
	
	def input_requirement(user_input)
    if user_input >= 1 && user_input <= 100
      true
    else
      false
    end
  end
  
  def user_input
    puts "Please enter a movie ranked between 1-100"
    user_input = (gets.strip).to_i
    if input_requirement(user_input) == true
      user_input
    else
      while input_requirement(user_input) != true
        puts "Invalid user selection. Please enter a index between 1-100."
        user_input = (gets.strip).to_i
      end
      user_input
    end
  end
  
  #Methods that either initialize or create movie objects
    
  def initialize_all_movies
    i = 0 
    while i < 100
      new_movie = Movie.new(i)
      i+=1
    end
  end
  
  def create_all_movies
    i = 0 
    while i < 100
      new_movie = Movie.create(i)
      i+=1
    end
  end
  
  def movie_initializer
    new_movie = Movie.new(user_input)
  end
  
  def print_movie_initializer
    new_movie = Movie.new(user_input)
    new_movie.print_basic_details
  end 
  
  def movie_creator
    new_movie = Movie.create(user_input)
  end
  
  def detailed_movie_initializer
    new_movie = Movie.new(user_input)
    self.class.movie_page_url(user_input)
    self.class.movie_page
    new_movie.detailed_initialize
    
  end
  
  def detailed_movie_creator
    
  end
end

class Movie
  
  #Class variables
  @@all = []
  @@my_watchlist = []
	
	attr_reader :imdb_ranking, :index, :title, :director, :year, :rating, :duration, :genres #:box_office, :awards, :metascore, :summary  #Reader methods that scrape basic details from IMDb Index Page
	
	attr_reader :actors, :characters, :actors_and_characters, :tagline, :detailed_plot, :official_website, :trivia, :quotes, :crazy_credits, :alternative_versions, :popular_references, :soundtracks #Reader methods that scrape in-depth details from movie's own IMDb page
	
	def initialize (imdb_ranking = nil) #initializes movie with basic details from IMDb Index Page
		@imdb_ranking = imdb_ranking
		@title = title
		@director = director
		@year = year
		@rating = rating
		@duration = duration
		@genres = genres
		self
	end 
	
	def detailed_initialize
	  @actors_and_characters = actors_and_characters
	  @tagline = tagline
	  @detailed_plot = detailed_plot
	  @official_website = official_website
	  @trivia = trivia
	  @quotes = quotes
	  @crazy_credits = crazy_credits
	  @alternative_versions = alternative_versions
	  @popular_references = popular_references
	  @popular_references = soundtracks
	  self
	end
	
	#Basic movie details scraped from summary IMDb Index Page
	def index
	  @imdb_ranking - 1
	end 
	
	def title
		Scraper.index_page.css("h3.lister-item-header a")[index].text.strip
	end
	
	def director
	  Scraper.index_page.css("p + p.text-muted.text-small > a:first-child")[index].text.strip
	end
	
	def year
	  Scraper.index_page.css("h3.lister-item-header span.lister-item-year.text-muted.unbold")[index].text.strip.gsub("(","").gsub(")","")
	end
	
	def rating
	  Scraper.index_page.css("span.certificate")[index].text.strip
	end
	
	def duration
	  Scraper.index_page.css("span.runtime")[index].text.strip
	end

	def genres
	  Scraper.index_page.css("span.genre")[index].text.strip
	end
	
	#def box_office
	  #Scraper.index_page.css("p.text-muted.text-small span.ghost + span.text-muted + span")[index].text.strip
	#end
	
	#def awards
	  #Scraper.index_page.css("div.clear + div.list-description p")[index].text.strip
	#end
	
	#def metascore
	  #Scraper.index_page.css("span.metascore.favorable")[index].text.strip
	#end
	
  #def summary
	 #if index == 14
	   #Scraper.index_page.css("div.ipl-rating-widget + p")[0].text.strip
	 #elsif index ==  90
	 	 #Scraper.index_page.css("div.ipl-rating-widget + p")[1].text.strip
	 #elsif index == 93
	   #Scraper.index_page.css("div.ipl-rating-widget + p")[2].text.strip
	 #elsif index == 99
	 	 #Scraper.index_page.css("div.ipl-rating-widget + p")[3].text.strip
	 #else
	   #Scraper.index_page.css("div.inline-block.ratings-metascore + p")[index].text.strip
	 #end
	#end
	
  #More in-depth movie details scraped from movie's individual IMDb page
	
	def actors
	  actors = []
	  cast_array = Scraper.movie_page.css("table.cast_list td.primary_photo + td a")
	  cast_array.collect{|actor| actors << actor.text.strip}
	  #i = 1 
	  #while i <= cast_array.count
	   # actors << cast_array[i].text.strip
	    #i+=2
	  #end
	  actors
	end
	
	def characters
	  characters = []
	  Scraper.movie_page.css("table.cast_list .character a").collect{|character| characters << character.text.strip}
	  characters
	end
	
	def actors_and_characters
	  cast_array = []
	  i = 0 
	  while i < actors.count
	    actor_role = actors[i].to_s + " - " + characters[i].to_s
	    cast_array << actor_role
	    i+=1
	  end
	  cast_array
	end
	
	def tagline
	   Scraper.movie_page.css("div.txt-block")[0].text.split("\n")[2].to_s.strip
	end
	
	def detailed_plot
	  Scraper.movie_page.css(".inline.canwrap").text.strip
	end
	
	def official_website
	  resource = Scraper.movie_page.css("#titleDetails div.txt-block a")[0]["href"]
	  if resource[0..7] != "/offsite"
	    official_website = nil
	  else
	    official_website = "www.imdb.com" + resource
	  end
	end
	
	def trivia
	  trivia = []
	  trivia_array = Scraper.movie_page.css("#trivia")[0].text.split("\n")
	  trivia_array[2..trivia_array.count].collect{|trivium| trivia << trivium.to_s.strip}
	  trivia
	end
	
	def quotes
	  quotes = []
	  quotes_array = Scraper.movie_page.css("#quotes")[0].text.split("\n")
	  quotes_array[2..quotes_array.count].collect{|quote| quotes << quote.to_s.strip}
	  quotes
	end
	
	def crazy_credits
	  crazy_credits = []
	  crazy_credits_array = Scraper.movie_page.css("#crazyCredits")[0].text.split("\n")
	  crazy_credits_array[2..crazy_credits_array.count].collect{|crazy_credit| crazy_credits << crazy_credit.to_s.strip }
	  crazy_credits
	end
	
	def alternative_versions
	  alternative_versions = []
	  alternative_versions_array = Scraper.movie_page.css("#alternativeVersions")[0].text.split("\n")
	  alternative_versions_array[2..alternative_versions_array.count].collect{|alternative_version| alternative_versions << alternative_version.to_s.strip}
	  alternative_versions
	end 
	
	def popular_references
	  popular_references = []
	  popular_references_array = Scraper.movie_page.css("#connections")[0].text.split("\n")
	  popular_references_array[2..popular_references_array.count].collect{|popular_reference| popular_references << popular_reference.to_s.strip}
	  popular_references
	end
	
	def soundtracks
	  soundtracks = []
	  soundtracks_array = Scraper.movie_page.css("#soundtracks")[0].text.split("\n")
	  soundtracks_array[2..soundtracks_array.count].collect{|soundtrack| soundtracks << soundtrack.to_s.strip}
	  soundtracks
	end
	
  #Methods that save movies to @@all class variable
  	

	
	def self.all
		@@all
	end
	
	def save
	  if self.class.all.find {|saved_movie| saved_movie.imdb_ranking == self.imdb_ranking} != nil
	   puts "Already saved. No duplicates allowed."
	   self
	 else
	   puts "Saved successfully."
	   self.class.all << self
	   self
	 end
	end
	
	
	def self.create(imdb_ranking = nil)
	  new_movie = self.new(imdb_ranking = nil)
	  new_movie.save
	  new_movie
	end
	
	#Methods that add movies to @@my_watchlist class variable
	

	def self.my_watchlist
		@@my_watchlist
	end
	
	def add_to_my_watchlist
	 if self.class.my_watchlist.find {|watchlisted_movie| watchlisted_movie.imdb_ranking == self.imdb_ranking} != nil
	   puts "Already added to my watchlist. No duplicates allowed."
	   self
	 else
	   puts "Added to my watchlist successfully."
	   self.class.my_watchlist << self
	   self
	 end
	end 
	
	def print_basic_details
	  puts "IMDb Top 100 Ranking: #{imdb_ranking}"
	  puts "Movie title: #{title}"
	  puts "Directed by: #{director}"
	  puts "Released in: #{year}"
	  puts "genres: #{genres}"
	  puts "Rated: #{rating}"
	  puts "Runtime: #{duration}"
  end
	
	def print_trivia
	  puts "Here is some interesting trivia about #{title}:"
	  puts trivia
	end
	
	def print_quotes
	  puts "#{title}'s most memorable quotes:"
	  puts quotes
	end
	
	def print_crazy_credits
    puts "Some fascinating credits: "
    puts crazy_credits
  end
  
  def print_popular_references
    puts "#{title} has been referenced in media like: "
    puts popular_references
  end
  
  def print_soundtracks
    "If you like this #{title}, you maye also be interested in these songs: "
    puts soundtracks
  end
  
  def print_my_watchlist
    puts "Would you like to add this movie to your watchlist? y or n"
    user_input = gets.strip.downcase
    if user_input == "y"
      add_to_my_watchlist
      puts "Here's your current watchlist: "
      puts @@my_watchlist.each{|movie| movie.print_title}
    elsif user-input == "n"
      puts "Noted. You do not want to see this film."
    end
  end
  
end
binding.pry