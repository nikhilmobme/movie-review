require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'json'
set :database, "sqlite3:formdatabase.sqlite3"
set :bind, '0.0.0.0'

def otpchange(email)
  File.open("forgotpw.txt", "wb") do |csv|
  otp = rand(1000000)
  content_type :json

  hash1 = {email =>  otp}
  hash1=hash1.to_json
  csv << hash1
  end
end
def input(email)
  File.open("out.txt", "wb") do |csv|
  csv << email
  end
end
def otpvalidation?(email)
  File.foreach('forgotpw.txt') do |row|
  parse=JSON.parse(row)
  parse.each do |email, otp|
    return otp
   
  end
  end
end

post '/login' do
  
  puts params.inspect
  if (params[:email].downcase == "admin" && params[:password] =="admin")
    response={:result=>"admin"}
  else  
	  @register = Register.find_by(:email=> params[:email])
    if @register
      if params[:email].downcase == @register.email
        if (@register.authenticate(params[:password])) 
    	    session[:id]=@register.id
          # if params[:password] == @register.password
		      response = {:result=> "success"}
        else
	        response =  {:result => "passworderror" }
        end
      end
    else
      response ={:result=>"usererror"}
    end
  end
  return response.to_json
end 
get '/index' do
  #@movie=Movie.select("id,moviename,language").find_by(:language=>"malayalam")
  @register = Register.all
  content_type :json
  #Register( :id , :desc)
  @register.to_json
end

post '/userinfo' do
  @register=Register.new
  @register.name=params[:name] 
  if (Register.find_by(:email=>params[:email]))
    response = {:result=> "email already exists"}
  elsif(params[:email]=~/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
    response = {:result=> "success"}
    @register.email=params[:email]
    if (params[:password].length >= 6)
      @register.password=params[:password]
      response= {:result=>"success"}
      @register.save
      input(@register.email)
      system("ruby email.rb -p 587")
    else
      response= {:result=>"invalid"}
    end
  else
    response = {:result=> "invalid email"}
  end
 
    return response.to_json
end

post '/adminhome' do
  puts params.inspect
  @movie=Movie.new
  @movie.moviename=params[:moviename].downcase
  @movie.language=params[:language].downcase
  @movie.rating=params[:rating]
  @movie.description=params[:description]
  @movie.producer=params[:producer]
  @movie.director=params[:director]
  @movie.maincast=params[:maincast]
  @movie.image=params[:image]
  @movie.save
end

post '/home/search' do 
  @movie = Movie.find_by(:moviename=> params[:moviename].downcase)
  return @movie.to_json
end

get '/edit/movielist' do
  @movie=Movie.select("id,moviename").order(id: :desc)
  content_type :json
  @movie.to_json
end

post '/edit/moviedetails' do
  puts params.inspect
  @movie=Movie.find_by(:moviename=> params[:moviename])
  content_type :json
  @movie.to_json
end
post '/moviedetails/comments' do
  puts params.inspect
  @review=Review.new
  @review.username=params[:email]
  @review.moviename=params[:moviename]
  @review.comments=params[:comments]
  @review.rating=params[:rating]
  @review.save
end
post '/view/comments' do
  puts params.inspect
 @review=Review.where(:moviename=>params[:moviename])

 #@review.username= Register.select("name").find_by(:email=> @review.username)
 content_type :json
 @review.to_json
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

post '/home/movielist' do
  @movie=Movie.select("moviename,rating,image").order(id: :desc)
  content_type :json
  return @movie.to_json
end

post '/home/movielist/language' do
  puts params.inspect
  @movie=Movie.select("moviename,rating,image").where(:language=>params[:language])
  content_type :json
  p @movie
  return @movie.to_json
end

post '/forum/comments' do
  #puts params.inspect
  @chat=Chat.new
  @chat.username=params[:email]
  @chat.language=params[:language]
  @chat.comments=params[:comments]
  #@forum.created_at=params[:created_at]
  @chat.save
end

post '/view/forum/comments' do
 puts params.inspect
 @chat=Chat.where(:language=>params[:language]).order(id: :desc)
 #@chat.username= Register.select("name").find_by(:email=> @chat.username)
 content_type :json
 @chat.to_json
end
post '/forgotpassword' do 
  puts params.inspect
  if(Register.find_by(:email=>params[:email]))

    email= params[:email]
    #h=system("ruby otpemail.rb -p 587")
    #puts h
    otpchange(email)
    system("ruby otpemail.rb")
    response={:result=>"success"}
 else
    response={:result=>"error"}
 end
   content_type :json
 return response.to_json
end
post '/forgotpassword/otp' do 
  resotp = params[:otp]
  email =params[:email]
  otp= otpvalidation?(email)
  otp =otp.to_s
  #puts otp.class
  #puts resotp.class
  if otp != resotp
    response = {:result=> "invalid"}
    puts "invalid"
  else
    response = {:result=> "success"}
    puts "success"
  end
  content_type :json
  return response.to_json
  #puts params.inspect
end
post '/newpassword' do
  puts params.inspect
  @register=Register.find_by(:email=>params[:email])
  @register.password=params[:password]
  @register.save
end


 
