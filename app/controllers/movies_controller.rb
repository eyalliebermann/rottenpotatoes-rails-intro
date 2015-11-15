class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end


  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort = params[:sort]
    if !@sort
      @sort= session[:sort]
      should_redirect = !!@sort && @sort.length>0
    end
    session[:sort] = @sort
  
   # @debug_status='params[:ratings] ==='+(params[:ratings] ||'nil') +'==='+'session==='+((session[:selected] && session[:selected].keys.to_s) || 'nil')+'==='

    if (params[:ratings] && params[:ratings].keys)
      @selected=params[:ratings] 
      #@debug_status+='A'
    else
      @selected=   session[:selected] || all_ratings_hash 
      should_redirect = true if !!@selected && @selected.keys.length>0
     # @debug_status= @debug_status +'B' + '===' + @selected.to_s + '===' + all_ratings_hash.to_s  + '==='  +Movie.all_ratings.to_s  
    end
    session[:selected] = @selected 

    if should_redirect
      flash.keep
      redirect_to movies_path( {:sort => @sort, :ratings => @selected})  
    end
  
    @movies = Movie.all
    
    @movies.where!({:rating =>  @selected.keys })
    @movies.order!(@sort) if @sort
    

    @all_ratings=Movie.all_ratings
  end
  
  def all_ratings_hash
    hash = Hash.new
    Movie.all_ratings.each do |item|
      hash[item]=1
    end
    hash
  end
    

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
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
