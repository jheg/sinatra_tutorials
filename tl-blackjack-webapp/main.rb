require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'jjjjhhheeegggg111999777666_-|||-_' 

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do
  def calculate_total(cards)
    arr = cards.map { |element| element[0] }

    total = 0
    arr.each do |val|
      if val == 'ace'
        total += 11
      else
        total += val.to_i == 0 ? 10 : val.to_i   
      end 
    end

    #correct for aces
    arr.select{|element| element == 'ace'}.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  def has_bust?(cards)
    if calculate_total(cards) > BLACKJACK_AMOUNT
      "Bust!"
    end
  end

  def winner!(msg)
    @playing = true
    @winning_message = "<strong>#{session[:player_name]} wins!</strong><br />#{msg}"
    session[:cash] += session[:player_bet]
    session[:biggest_win] < session[:player_bet] ? session[:biggest_win] = session[:player_bet] : session[:biggest_win]
    session[:win_streak] += 1
    session[:losing_streak] = 0
    session[:wins] += 1
    session[:best_streak] < session[:win_streak] ? session[:best_streak] = session[:win_streak] : session[:best_streak] 
    @bust_or_stay = true
  end
  
  def loser!(msg)
    @playing = true
    @losing_message = "<strong>#{session[:player_name]} loses.</strong><br />#{msg}"
    session[:cash] -= session[:player_bet]
    session[:biggest_loss] < session[:player_bet] ? session[:biggest_loss] = session[:player_bet] : session[:biggest_loss]    
    session[:losses] += 1
    session[:win_streak] = 0
    session[:losing_streak] += 1
    session[:worst_streak] < session[:losing_streak] ? session[:worst_streak] = session[:losing_streak] : session[:worst_streak]
    @bust_or_stay = true
  end

  def tie!(msg)
    @playing = true
    @winning_message = "<strong>It's a tie!</strong><br />#{msg}"
    session[:win_streak] = 0
    session[:losing_streak] = 0
  end

  def play_again
    redirect '/game'
  end
end

before do 
  @bust_or_stay = false
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:cash] = 500
  session[:biggest_win] = 0
  session[:biggest_loss] = 0
  session[:wins] = 0
  session[:win_streak] = 0
  session[:best_streak] = 0
  session[:losses] = 0
  session[:losing_streak] = 0
  session[:worst_streak] = 0
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @have_name = "Please tell me your name "
    halt erb(:new_player)
  end
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "Must make a bet."
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:cash]
    @error = "You can't bet with money you don't have! Bet between 0 and #{session[:cash]}."
    halt erb(:bet)
  elsif params[:bet_amount].to_i < 0
    @error = "Quite the character aren't you. Bet between 0 and #{session[:cash]}."
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do
  @players_turn = true
  # create deck and put in session
  suits = ['hearts', 'spades', 'clubs', 'diamonds']
  values = %w{ace 2 3 4 5 6 7 8 9 10 jack queen king}
  session[:deck] = values.product(suits).shuffle! # => [['4', 'S'],['10', 'C'],['a', 'D']...]


  # deal cards
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do 
  @players_turn = true
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner!("You hit blackjack. You win!")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("Bust. You lose :(")
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "Stay"
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_next_card = false
  @players_turn = false
  @bust_or_stay = true

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!('Sorry, dealer hit blackjack!')
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!('Congratulations, dealer busted. You win!')
  elsif dealer_total >= DEALER_MIN_HIT
    redirect '/game/compare'
  else
    @show_next_card = true
  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_next_card = false
  @players_turn = false
  @bust_or_stay = true
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])
  if player_total == dealer_total
    tie!("You both got #{player_total}")
  elsif player_total > dealer_total
    winner!("You got #{player_total} and the dealers total was #{dealer_total}")
  else
    loser!("You got #{player_total} and the dealers total was #{dealer_total}")
  end
  erb :game

end

get '/goodbye' do
  erb :goodbye
end

