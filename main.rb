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

  def card_image(card)

    if ["A","J","Q","K"].include?(card[1])
      value = case card[1]
        when "A" then "ace"
        when "J" then "jack"
        when "Q" then "Queen"
        when "K" then "king"
        end
    else
      value = card[1]
    end

    "<img src='/images/cards/#{card[0]}_#{value}.jpg' class='poker'>"
  end


end

get '/' do
  if session[:player]
    redirect '/game'
  end
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:name]
  if params[:name].empty?
    @error = "You must enter your name!"
    halt erb :set_name
  end
  redirect '/game'
end

# get '/bet' do
# end

# post '/set_bet' do
# end

before do
  @show_hit_and_stand_button = true
end

get '/game' do
  if !session[:player_name]
    redirect '/'
  end
  value = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  suit = %w(spades hearts diamonds clubs)
  session[:deck] = suit.product(value).shuffle!
  session[:player_cards] = []
  session[:dealer_cards] = []
  2.times do 
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end

  player_total = add_up_total(session[:player_cards])
  if player_total == 21
    @success = "#{player_name} hits blackjack! #{player_name} wins!"
  end
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  total = add_up_total(session[:player_cards])
  if total == 21
    @success = "#{session[:player_name]} hits blackjack! #{session[:player_name]} wins!"
    @show_hit_and_stand_button = false
  elsif total > 21
    @error = "#{session[:player_name]} busted! Dealer wins!"
    @show_hit_and_stand_button = false
  end
  erb :game
end

post '/game/player/stay' do
  @show_hit_and_stand_button = false
  erb :game
  redirect '/game/dealer'
  @success = "#{session[:player_name]} chose to stand."
end

get '/game/dealer' do 
  @show_hit_and_stand_button = false
  @player = "Dealer"

  dealer_total = add_up_total(session[:dealer_cards])
  if dealer_total == 21
    @error = "Dealer hits blackjack! #{session[:player_name]} lost!"
  elsif dealer_total > 17 
    redirect "/game/compare"
    @success = "Dealer chooses stand!"
  else 
    @show_dealer_hit_button = true
  end

  erb :game

end

post '/game/dealer/hit' do
  @show_hit_and_stand_button = false
  session[:dealer_cards] << session[:deck].pop

  dealer_total = add_up_total(session[:dealer_cards])
  if dealer_total == 21
    @error = "Dealer hits blackjack! Dealer wins!"
  elsif dealer_total > 21
    @success = "Dealer busted! #{player_name} wins!"
  elsif dealer_total > 17
    @success = "Dealer stand"
    redirect 'game/compare'
  else 
    @show_dealer_hit_button = true
  end
    

  erb :game
    
end

get '/game/compare' do 
  @show_dealer_hit_button = false
  @show_hit_and_stand_button = false

  player_total = add_up_total(session[:player_cards])
  dealer_total = add_up_total(session[:dealer_cards])

  if player_total > dealer_total
    @success = "#{session[:player_name]} has #{player_total}, #{session[:player_name]} wins!"
    erb :game
  elsif dealer_total > player_total 
    @error = "Dealer has #{dealer_total}, Dealer wins!"
    erb :game
  else 
    @success = "It's a push!"
    erb :game
  end
      
end


get '/logout' do
  session.clear
  redirect '/'

end



