class Card
  attr_reader :face_value, :suit

  def initialize(facevalue, suitvalue)
    @face_value = facevalue
    @suit = suitvalue
  end

  def to_s
    "#{face_value} - #{suit}"
  end

end

class Deck
  attr_accessor :cards

  FACES = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

  SUITS = ["Spades", "Hearts", "Clubs", "Diamonds"]

  def initialize
    @cards = []
    @faces = FACES

    SUITS.each do |suit|
      @faces.each do |facevalue|
        @cards << Card.new(facevalue, suit)
      end
    end
    shuffle_deck
  end

  def shuffle_deck
    cards.shuffle!
  end

  def deal_card
    cards.pop
  end

  def card_count
    cards.size
  end

end

module Hand
  FACE_VALUES = {"1" => 1, "2" =>2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, \
  "8" => 8, "9" => 9, "10" => 10, "J" => 10, "Q" => 10, "K" => 10}

  def show_hand
    puts "**** #{name}'s Hand ****"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "=> Count is: #{get_hand_value[0]} #{:or if !get_hand_value[1].nil?} #{get_hand_value[1] if !(get_hand_value[1].nil?)}"
    puts
  end

  def show_one_card
    puts "**** #{name}'s Hand ****"
    puts "=> #{cards.first}"
    puts "=> ## - ?????"
    puts
  end

  def get_hand_value
    sum = [0]
    values = []

    cards.each do |card|
      sum[0] += FACE_VALUES[card.face_value]
      values.push(card.face_value)
    end

    if values.include?("1")
      sum[1] = sum[0] + 10
      if sum[1] > 21
        sum[2] = sum[0]
      else
        sum[2] = sum[1]
      end
    end
    sum
  end

  def add_card(card)
    cards << card
  end

  def is_busted?
    get_hand_value.first > 21
  end

  def is_natural_21?
    !get_hand_value[1].nil? && get_hand_value[1] == 21 && cards.count == 2
  end

end

class Player
  include Hand
  attr_accessor :chip_count, :name, :cards

  def initialize(name, cc)
    @name = name
    @cards = []
    @chip_count = cc
  end

  def adjust_chip_count(amount)
    @chip_count += amount.to_i
  end

end

class Blackjack
  attr_accessor :deck, :dealer, :player
  attr_reader :min_bet, :max_bet, :player_bet

  def initialize
    player_name = get_user_name
    player_chipcount = get_user_chipcount
    @player = Player.new(player_name, player_chipcount)
    @dealer = Player.new("Dealer", 10000)
    @min_bet = 10
    @max_bet = 500
    @deck = Deck.new()
  end

  def number_is_multiple_of_10?(num)
    num % 10  == 0
  end

  def number_at_least_100?(num)
    num > 99
  end

  def get_user_name
    puts "What is your name?"
    gets.chomp.capitalize
  end

  def get_user_chipcount
    begin
      puts
      puts "How many chips do you want to play with?"
      puts "Number must be at least 100, multiple of 10"
      count = gets.chomp.to_i
    end until (number_at_least_100?(count) && number_is_multiple_of_10?(count))
    count
  end

  def take_bet
    player.chip_count < max_bet ? upper_limit = player.chip_count : upper_limit = max_bet

    begin
      puts
      puts "How much do you want to bet?"
      puts "Number must between #{min_bet} and #{upper_limit}, and is multiple of 10"
      bet = gets.chomp.to_i
    end until (number_is_multiple_of_10?(bet) && (bet < (upper_limit + 1)) && (bet  > (min_bet - 1)))
    @player_bet = bet
  end

  def show_dealer_hidden
    sleep 0.5
    system("clear")
    dealer.show_one_card
    player.show_hand
    puts "Current Bet: $#{player_bet}"
    puts
  end

  def show_all_cards
    sleep 0.5
    system("clear")
    player.show_hand
    dealer.show_hand
    puts "Current Bet: $#{player_bet}"
    puts
  end

  def take_player_action
    begin
      puts "Do you want to Hit or Stay? (enter H or S only)"
      user_move = gets.chomp.upcase
    end until user_move == "H" || user_move == "S"
    user_move
  end

  def finish_player_hand
    begin
      move = take_player_action
      case move
      when "H"
        player.add_card(deck.deal_card)
        show_dealer_hidden
      when "S"
        next
      else
        puts "ERROR in Player action loop."
        exit
      end
    end until move == "S"|| player.is_busted?
  end

  def game_reset
    @deck = Deck.new()
    player.cards = []
    dealer.cards = []
  end

  def dealer_finish_hand
    if dealer.get_hand_value.last < 17
      begin
        show_all_cards
        dealer.add_card(deck.deal_card)
        sleep 0.5
      end until dealer.get_hand_value.last > 16
    end
  end

  def player_wins
    show_all_cards
    puts "You have #{player.get_hand_value.last} and dealer has #{dealer.get_hand_value.last}."
    puts "You win $#{player_bet} for this hand"
    player.chip_count += player_bet
    dealer.chip_count -= player_bet
  end

  def player_loses
    show_all_cards
    puts "You have #{player.get_hand_value.last} and dealer has #{dealer.get_hand_value.last}."
    puts "You lose $#{player_bet} for this hand"
    player.chip_count -= player_bet
    dealer.chip_count += player_bet
  end

  def player_out_of_chips?
    if player.chip_count < min_bet
      puts "Sorry, you are out of money!  Good bye!"
      exit
    end
  end

  def natural_21_check

  end

  def new_game
    begin
      game_reset
      #need to add play again loop
      take_bet

      #deal initial cards
      2.times {player.add_card(deck.deal_card)}
      2.times {dealer.add_card(deck.deal_card)}

      #show initial hand
      show_dealer_hidden

      #check if dealer or player is natural 21
      if dealer.is_natural_21?
        show_all_cards
        if player.is_natural_21?
          puts "Dealer has Blackjack.  #{player.name} also has Blackjack.  You Tie!"
        else
          puts "Dealer has Blackjack. You lose this hand."
          player_loses
        end
      elsif player.is_natural_21?
        show_all_cards
        puts "You have a Blackjack.  You win this hand!"
        player.chip_count += player_bet * 1.5
        dealer.chip_count -= player_bet * 1.5
        puts "You won $#{player_bet} for this hand"
      else
        finish_player_hand
      end

      if player.is_busted?
        player_loses
      else
        dealer_finish_hand
        if dealer.is_busted? || (player.get_hand_value.last > dealer.get_hand_value.last)
          player_wins
        else
          player_loses
        end
      end

      player_out_of_chips?

      puts "Your current chip count: $#{player.chip_count}"
      puts "Do you want to play more hands? y/n"
      play_again = gets.chomp
    end until play_again != "y"
  end
end

game = Blackjack.new()
game.new_game




