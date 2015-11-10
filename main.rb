require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret' 

helpers do 
  def add_up_total
  end
end

get '/' do
  erb :set_name
  if session[:player_name]
    redirect '/game'
  end
end

post '/set_name' do
  # binding.pry
  session[:player_name] = params[:name]
  redirect '/game'
end

get '/bet' do
end

get '/game' do
  value = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  suit = %w(Spade Heart Diamond Club)
  session[:deck] = suit.product(value)
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  erb :game
end