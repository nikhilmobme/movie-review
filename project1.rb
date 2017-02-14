require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'json'
#require 'byebug'
set :database, "sqlite3:formdatabase.sqlite3"
set :bind, '0.0.0.0'


post '/login' do
  #byebug
  puts params.inspect
  if (params[:email].downcase == "admin" && params[:password] =="admin")
     response={:result=>"admin"}
  else
  
	@register = Register.find_by(:email=> params[:email])
  if @register
    if params[:email].downcase == @register.email 
        if params[:password] == @register.password
		 response = {:result=> "success"}
        else
	     response =  {:result => "passworderror" }
        end
    end
    else
     	response = {:result=>"usererror"}
    end
 end
   return response.to_json
end
   
get '/index' do
	
	@movie=Movie.select(:id,:moviename,:language,:rating).order(id: :desc)
	content_type :json
	#Register( :id , :desc)
	@movie.to_json
end

post '/userinfo' do
    @register=Register.new
    @register.name=params[:name]
    @register.email=params[:email]
    @register.password=params[:password]
    @register.save
end

post '/adminhome' do
	    puts params.inspect
        @movie=Movie.new
		@movie.moviename=params[:moviename]
		@movie.language=params[:language]
		@movie.rating=params[:rating]
		@movie.description=params[:description]
		@movie.producer=params[:producer]
		@movie.director=params[:director]
	    @movie.maincast=params[:maincast]
	    @movie.image=params[:image]
        @movie.save
end

post '/home/search' do 
	@movie = Movie.find_by(:moviename=> params[:moviename])
	return @movie.to_json
end

post '/home/language' do
	 @movie=Movie.find_by(:language =>params[:language])
	 #@movie( id: , :desc)
	 return @movie.to_json
end



get '/edit/movielist' do
    @movie=Movie.select("id,moviename").order(id: :desc)
	content_type :json
	@movie.to_json

end

post '/edit/moviedetails' do
        puts params.inspect
		@movie=Movie.find_by(:moviename=> params[:moviename] )
		content_type :json
        @movie.to_json
end
post '/moviedetail/update' do
	 puts params.inspect
	if (@movie = Movie.find_by(:id=> params[:movieid]))
	
	@movie.moviename= params[:moviename]
	@movie.language= params[:language]
	@movie.rating=params[:rating]
	@movie.description=params[:description]
	@movie.image=params[:image]
	@movie.director=params[:director]
	@movie.producer=params[:producer]
	@movie.maincast=params[:maincast] 
	@movie.save
    content_type :json
    @movie.to_json
    else
	puts "not found"
    end
end


# movie-review
