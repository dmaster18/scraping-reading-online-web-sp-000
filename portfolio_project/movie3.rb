require 'nokogiri'
require 'open-uri'
require 'pry'
require 'action_view'

class Scraper
  
  #Methods that interface with the IMDb HTML
  
  def self.index_page #Retrieves Nokogiri data from IMDb Index Page
    index_html = open("https://www.imdb.com/list/ls055592025/")
    Nokogiri::HTML(index_html)
  end
  
  def movie_page_url(movie_object) #Generates selected movie's IMDb page HTML
	  index = movie_object.index
	  resource = self.class.index_page.css(".lister-item-header a")[index]["href"]
	  movie_page_url = "https://www.imdb.com" + resource
  end
  
  def movie_page(movie_object) #Retrieves Nokogiri data from selected movie's IMDb page
    movie_html = open(movie_page_url(movie_object))
    Nokogiri::HTML(movie_html)
  end
  
  def trivia_page_url(movie_object) #Generates selected movie's IMDb trivia page HTML
	  movie_page = movie_page(movie_object)
	  movie_page_url = movie_page_url(movie_object)
	  resource = movie_page.css("div#trivia a.nobr")[0]["href"].to_s
	  trivia_page_url = movie_page_url.to_s + resource
  end
  
  def trivia_page(movie_object) #Retrieves Nokogiri data from selected movie's IMDb trivia page
    trivia_html = open(trivia_page_url(movie_object))
    Nokogiri::HTML(trivia_html)
  end
  
  def quotes_page_url(movie_object) #Generates selected movie's IMDb trivia page HTML
	  movie_page = movie_page(movie_object)
	  movie_page_url = movie_page_url(movie_object)
	  resource = movie_page.css("div#quotes a.nobr")[0]["href"].to_s
	  quotes_page_url = movie_page_url.to_s + resource
  end
  
  def quotes_page(movie_object) #Retrieves Nokogiri data from selected movie's IMDb trivia page
    quotes_html = open(quotes_page_url(movie_object))
    Nokogiri::HTML(quotes_html)
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
    new_movie = Movie.new
  end
  
  def movie_creator
    new_movie = Movie.create
  end
  
  def detailed_movie_initializer(movie_object)
    movie_object.movie_page
    movie_object.print_detailed_initialize
  end
  
  def detailed_movie_creator
    
  end
end

class CLI

  def start
    puts "Here's a list of IMDb's Top 100 Movies:"
    puts "\n"
    Scraper.print_movie_list
    scraper = Scraper.new
    user_input = "y"
    while user_input == 'y'
      movie = scraper.movie_initializer
      movie.print_basic_details
      puts "\nWould you like to know more information about #{movie.title}?" 
      puts "Please enter 'y' for yes or 'n' for no."
      user_input = gets.strip.downcase
      watchlist_response = nil
      while user_input == 'y'
        movie.ask_user
        user_input = gets.strip.to_i
        if user_input == 1
          movie.print_tagline
        elsif user_input == 2
          movie.print_plot
        elsif user_input == 3
          movie.print_trivia
        elsif user_input == 4
          movie.print_quotes
		    elsif user_input == 5
          movie.print_cast
        end
		    if Movie.my_watchlist.include?(movie) != true && watchlist_response == nil
			    puts "\nWould you like to add this movie to your watchlist?"
			    puts "Please enter 'y' for yes or 'n' for no"
			    user_input = gets.strip
			    if user_input == 'y'
				    watchlist_response = 'y'
				    movie.add_to_my_watchlist
			    else
			      watchlist_response = 'n'
				    puts "\nNoted. You do not want to add this movie to your watchlist."
			    end	
		    end
		    puts "\nWould you like to know more about #{movie.title}?"
        puts "Please enter 'y' for yes or 'n' for no"
        user_input = gets.strip
      end
	  puts "Okay, exiting #{movie.title} now..."
	  puts "Would you like to research another movie?"
      puts "Please enter 'y' for yes or 'n' for no"
      user_input = gets.strip.downcase
  end
	puts "Would you like to view your watchlist?"
	puts "Please enter 'y' for yes or 'n' for no"
  user_input = gets.strip.downcase
	if user_input == 'y'
		Movie.print_my_watchlist
	end
	puts "Thank you for using viewing IMDb's Top 100 Movie List!"
  end
end


class Movie
  
  #Class variables
  @@viewed = []
  @@my_watchlist = []
	
	attr_reader :imdb_ranking, :index, :title, :director, :year, :rating, :duration, :genres #Reader methods that scrape basic details from IMDb Index Page
	
	attr_reader :actors, :characters, :cast, :tagline, :plot, :trivia, :quotes #Reader methods that scrape in-depth details from movie's own IMDb page
	
	def initialize (imdb_ranking = nil) #initializes movie with basic details from IMDb Index Page
		if imdb_ranking == nil 
		  user_input
		else
		  @imdb_ranking = imdb_ranking
		end
		@title = title
		@director = director
		@year = year
		@rating = rating
		@duration = duration
		@genres = genres
		save
		self
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
        @imdb_ranking = user_input
      else
        while input_requirement(user_input) != true
          puts "Invalid user selection. Please enter a index between 1-100."
          user_input = (gets.strip).to_i
        end
      @imdb_ranking = user_input
      end
      @imdb_ranking
  end
	
	#Basic movie details scraped from summary IMDb Index Page
	def index
	  @imdb_ranking.to_i - 1
	end 
	
	def index_page
	  Scraper.index_page
	 end
	
	def title
		index_page.css("h3.lister-item-header a")[index].text.strip
	end
	
	def director
	  index_page.css("p + p.text-muted.text-small > a:first-child")[index].text.strip
	end
	
	def year
	  index_page.css("h3.lister-item-header span.lister-item-year.text-muted.unbold")[index].text.strip.gsub("(","").gsub(")","")
	end
	
	def rating
	  index_page.css("span.certificate")[index].text.strip
	end
	
	def duration
	  index_page.css("span.runtime")[index].text.strip
	end

	def genres
	  index_page.css("span.genre")[index].text.strip
	end
	
  #More in-depth movie details scraped from movie's individual IMDb page
	
	def movie_page
	  Scraper.new.movie_page(self)
	end
	
	def trivia_page
	  Scraper.new.trivia_page(self)
	end
  
	
	def quotes_page
	  Scraper.new.quotes_page(self)
	end
	
	def ask_user
	   puts "Enter (1) if you'd like to know #{title}'s tagline.\nEnter (2) if you'd like to know #{title}'s plot.\nEnter (3) if you'd like to know interesting trivia about #{title}.\nEnter (4) if you'd like to hear some of the most famous quotes from #{title}.\nEnter (5) if you'd like to know #{title}'s cast and crew."
	 end
	
	def tagline
	   movie_page.css("div.txt-block")[0].text.split("\n")[2].to_s.strip
	end
	
	def print_tagline
	  puts "\nTagline: #{tagline}"
	end
	
	def plot
	  unedited_plot = movie_page.css(".inline.canwrap").text.strip
	  plot = unedited_plot.slice(0, unedited_plot.index("Written by")).strip
	end
	
	def print_plot
	  puts "\nPlot: #{plot}"
	end

	def trivia
	  trivia = []
	  trivia_array = trivia_page.css("div.sodatext")
	  i = 1
	  trivia_array.collect{|trivium| 
	    trivia << "\nFun Fact ##{i}: #{ActionView::Base.full_sanitizer.sanitize(trivium.to_s.strip)}"
	    i+=1
	  }
	  trivia
	end
	
	def more_fun_facts
	  	puts "\nWould you like to see fifty more fun facts about #{title}?"
	    puts "Enter 'y' for yes and 'n' for no."
	    user_input = gets.strip
	end  
	
	def print_trivia
		puts "\nHere are fifty fun facts about #{title}:"
		i = 1
		user_input = 'y'
		
		while i <= 300 && user_input == 'y'
		  
		  while i <= 50
		    puts "\n"
		    puts trivia[0..49]
		    i+=50
		    if trivia[0..49].count == 50
		      user_input = more_fun_facts
		    else
		      user_input == 'n'
		    end
		  end
		  
	    while i >50 && i <=100 && user_input == 'y'
	    	puts "\n"
		    puts trivia[50..99]
		    i+=50
		    if trivia[50..99].count == 50
		      user_input = more_fun_facts
		    else
		      user_input == 'n'
		    end
	    end
	    
	    while i > 100 && i <= 150 && user_input == 'y'
		    puts "\n"
		    puts trivia[100..149]
		    i+=50
		    if trivia[100..149].count == 50
		      user_input = more_fun_facts
		    else
		      user_input == 'n'
		    end
	    end
	
	    while i > 150 && i <= 200 && user_input == 'y'
	 		  puts "\n"
	 		  puts trivia[150..199]
	 		  i+=50
	 		  if trivia[150..199].count == 50
		      user_input = more_fun_facts
		    else
		      user_input == 'n'
		    end
	    end
	    
	    while i > 200 && i <= 250 && user_input == 'y'
		    puts "\n"
		    puts trivia[200..249]
		    i+=50
		    if trivia[200..249].count == 50
		      user_input = more_fun_facts
		    else
		      user_input == 'n'
		    end
	    end
	    
	    while i > 250 && i <= 300 && user_input == 'y'
		    puts "\n"
		    puts trivia[250..299]
		    i+=50
	    end
	 end
	end
	
	def quotes
	  quotes = []
	  quotes_array = quotes_page.css("div.sodatext")
	  i = 1
	  quotes_array.collect{|quote| 
	    quotes << "\nQuote ##{i}: #{ActionView::Base.full_sanitizer.sanitize(quote.to_s.strip)}"
	    i+=1
	  }
	  quotes
	end
	
	def more_quotes
	  	puts "\nWould you like to see fifty more memorable quotes from #{title}?"
	    puts "Enter 'y' for yes and 'n' for no."
	    user_input = gets.strip
	end  
	
	
	def print_quotes
		puts "Here are some of #{title}'s most memorable quotes:"
		i = 1
		user_input = 'y'
		
		while i <= 300 && user_input == 'y'
		  
		  while i <= 50
		    puts "\n"
		    puts quotes[0..49]
		    i+=50
		    if quotes[0..49].count == 50
		      user_input = more_quotes
		    else
		      user_input = 'n'
		    end
		  end
		  
	    while i >50 && i <=100 && user_input == 'y'
	    	puts "\n"
		    puts quotes[50..99]
		    i+=50
		    if quotes[50..99].count == 50
		      user_input = more_quotes
		    else
		      user_input = 'n'
		    end
	    end
	    
	    while i > 100 && i <= 150 && user_input == 'y'
		    puts "\n"
		    puts quotes[100..149]
		    i+=50
		    if quotes[100..149].count == 50
		      user_input = more_quotes
		    else
		      user_input = 'n'
		    end
	    end
	
	    while i > 150 && i <= 200 && user_input == 'y'
	 		  puts "\n"
	 		  puts quotes[150..199]
	 		  i+=50
	 		  if quotes[150..199].count == 50
		      user_input = more_quotes
		    else
		      user_input = 'n'
		    end
	    end
	    
	    while i > 200 && i <= 250 && user_input == 'y'
		    puts "\n"
		    puts quotes[200..249]
		    i+=50
		    if quotes[200..249].count == 50
		      user_input = more_quotes
		    else
		      user_input = 'n'
		    end
	    end
	    
	    while i > 250 && i <= 300 && user_input == 'y'
		    puts "\n"
		    puts quotes[250..299]
		    i+=50
	    end
	 end
	end
	
	def actors
	  actors = []
	  cast_array = movie_page.css("table.cast_list td.primary_photo + td a")
	  cast_array.collect{|actor| actors << actor.text.strip}
	  actors
	end
	
	def characters
	  characters = []
	  movie_page.css("table.cast_list .character a").collect{|character| characters << character.text.strip}
	  characters
	end
	
	def cast
	  cast_array = []
	  i = 0 
	  while i < actors.count
	    actor_role = actors[i].to_s + " - " + characters[i].to_s
	    cast_array << actor_role
	    i+=1
	  end
	  cast_array
	end
	
	def print_cast
	  puts "\nThe movie's cast consists of #{cast}"
	end
	
	def detailed_initialize
	  @tagline = tagline
	  @plot = plot
	  @trivia = trivia
	  @quotes = quotes
	  self
	end
	
	def print_detailed_initialize
	  puts "Tagline: #{tagline}"
	  puts "Plot: #{plot}"
	  puts "Trivia: #{trivia}"	
    puts "Quotes: #{quotes}"
	end
	
  #Methods that save movies to @@viewed class variable
  	

	def self.viewed
		@@viewed
	end
	
	def save
	  if self.class.viewed.find {|saved_movie| saved_movie.imdb_ranking == self.imdb_ranking} != nil
	   self
	 else
	   self.class.viewed << self
	   self
	 end
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
	
	def self.print_my_watchlist
		puts "Here's your current watchlist: "
		movie_titles = []
		i = 1
		self.my_watchlist.each{|movie| 
		movie_titles << "#{i}. #{movie.title}"
		i += 1
		}
		puts movie_titles
	end
	#Print methods
	
	def print_basic_details
	  puts "IMDb Top 100 Ranking: #{imdb_ranking}\nMovie title: #{title}\nDirected by: #{director}\nReleased in: #{year}\nGenre(s): #{genres}\nRated: #{rating}\nRuntime: #{duration}"
	end
end
binding.pry


