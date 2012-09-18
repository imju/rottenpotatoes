class MoviesController < ApplicationController
  
  def initialize()
    @all_ratings = Array.new
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  

  def index

    Movie.select("distinct rating").each do |m|
      #logger.debug('rating:'+m.rating) 
      @all_ratings<<m.rating
    end  
#    debugger    
    is_redirect = false 
    ratings = params[:ratings]
    sort_by = params[:sort_by]
#    session.clear
=begin
    if ratings and ratings.size > 0
        ratings_condition = ratings.keys
    end 
=end
  
    if ratings and ratings.size > 0
        ratings_condition = ratings.keys
        session.delete(:ratings)
        session[:ratings] = ratings
    elsif session[:ratings] and session[:ratings].size > 0
          is_redirect = true    
          ratings = session[:ratings]
    end 
    
    
    if sort_by
      session.delete(:sort_by)
      session[:sort_by] = sort_by
    elsif session[:sort_by] 
      sort_by = session[:sort_by] 
      is_redirect = true      
    end

    if is_redirect
      logger.debug('redirect>>')
      flash.keep
      redirect_to movies_path ({:sort_by => sort_by, :ratings => ratings})
      return
    end

    logger.debug('rating conditions:'+ratings_condition.inspect)
    #logger.debug('sort by:'+sort_by)
    
    if sort_by
      if ratings_condition
         @movies = Movie.where(:rating => ratings_condition).order(sort_by)               
      else
         @movies = Movie.order(sort_by)
      end                                     
    else   
      if ratings_condition
         @movies = Movie.where(:rating => ratings_condition)       
      else
         @movies = Movie.all
      end   
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
