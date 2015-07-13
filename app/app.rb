require 'sinatra/base'
require './app/data_mapper_setup.rb'
require 'sinatra/flash'

class MakersMunch < Sinatra::Base
  run! if app_file == $0
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  get '/restaurant/new' do
    erb :'restaurant/new'
  end

  post '/restaurant/new' do
    @restaurant = Restaurant.create(name: params[:name], post_code: params[:post_code])
    tags = params[:tag].split(' ')
    tags.each do |tag|
      @restaurant.tags << Tag.create(name: tag)
    end
    @restaurant.save
    if @restaurant.save
      redirect to('/restaurants')
    else
      flash.now[:errors] = @restaurant.errors.full_messages
    end
  end

  get '/restaurants' do
    @restaurants = Restaurant.all
    erb :'restaurant/list'
  end

  get '/' do
    erb :index
  end

  get '/user/new' do
    @user = User.new
    erb :'user/new'
  end

  post '/user/new' do
    @user = User.create(full_name: params[:full_name],  email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])

    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'user/new'
    end
  end

  get '/log_in' do
    erb :'session/new'
  end

  post '/log_in' do
    user = User.authenticate(email: params[:email], password: params[:password])
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash.now[:errors] = ['The email or password is incorrect']
      erb :'session/new'
    end
  end

  delete '/log_in' do
    session[:user_id] = nil
    flash[:notice] = 'Goodbye!'
    redirect to('/')
  end


  helpers do
      def current_user
         @current_user ||= User.get(session[:user_id])
       end
    end

  not_found do
    erb :error
  end

  get '/tags/:name' do
    tag = Tag.first(name: params[:name])
    @restaurants = tag ? tag.restaurants : []
    erb :'restaurant/list'
  end
end
