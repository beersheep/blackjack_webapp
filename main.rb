require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret' 

helpers do 

  def add_up_total(cards)
    card_value = cards.map{|card| card[1]}
    total = 0

    card_value.each do |value|
      if value == "A"
        total += 11
      else
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end

    card_value.select {|value| value == "A"}.count.times do
      break if total <= 21
      total -= 10 
    end
    total
  end


end

get '/' do
  if session[:player_name]
    redirect '/game'
  end
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:name]
  redirect '/game'
end

get '/bet' do
end

post '/set_bet' do
end

get '/game' do
  if !session[:player_name]
    redirect '/'
  end
  value = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  suit = %w(spade heart diamond club)
  session[:deck] = suit.product(value).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  2.times do 
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if add_up_total(session[:player_cards]) > 21
    @error = "#{session[:player_name]} busted! Dealer wins!"
  end
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} chose to stay."

  erb :game
end

get '/logout' do
  session.clear
  redirect '/'

end



