FACES_VALUES = {"1" => 1, "2" =>2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, \
"8" => 8, "9" => 9, "10" => 10, "J" => 10, "Q" => 10, "K" => 10}

SUITS = ["Spades", "Hearts", "Clubs", "Diamonds"]

# def num_is_123?(num)
#   num == 1 || num == 2 || num == 3
# end

# def say(string)
#   puts "==> #{string}"
# end

def num_is_mult_of_10?(num)
  num % 10  == 0
end

def num_at_least_100?(num)
  num > 99
end

class Card
  attr_reader :face_value, :suit

  def initialize(fv, s)
    @face_value = fv
    @suit = s
  end

  def to_s
    "#{face_value} - #{suit}"
  end

end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    @faces = FACES_VALUES.keys

    SUITS.each do |suit|
      @faces.each do |fv|
        @cards << Card.new(fv, suit)
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

  def show_hand
    puts "**** #{name}'s Hand ****"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "=> Count is: #{get_count[0]} #{:or if !get_count[1].nil?} #{get_count[1] if !(get_count[1].nil?)}"
    puts
  end

  def show_one_card
    puts "**** #{name}'s Hand ****"
    puts "=> #{cards.first}"
    puts "=> ## - ?????"
    puts
  end

  def get_count
    sum = [0]
    values = []

    cards.each do |card|
      sum[0] += FACES_VALUES[card.face_value]
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
    get_count.first > 21
  end

  def is_natural_21?
    !get_count[1].nil? && get_count[1] == 21 && cards.count == 2
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

  # #do I need this?
  # def print_table
  # end

  def get_user_name
    puts "What is your name?"
    gets.chomp().capitalize
  end

  def get_user_chipcount
    begin
      puts
      puts "How many chips do you want to play with?"
      puts "Number must be at least 100, multiple of 10"
      count = gets.chomp().to_i
    end until (num_at_least_100?(count) & num_is_mult_of_10?(count))
    count
  end

  def take_bet
    begin
      puts
      puts "How much do you want to bet?"
      puts "Number must between #{min_bet} and #{max_bet}, and is multiple of 10"
      bet = gets.chomp().to_i
    end until (num_is_mult_of_10?(bet) & (bet < (max_bet + 1)) & (bet  > (min_bet - 1)))
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

  def game_reset
    @deck = Deck.new()
    player.cards = []
    dealer.cards = []
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
          #skips to "do you want to play again??"
        else
          puts "Dealer has Blackjack. You lose this hand."
          player.chip_count -= player_bet
          dealer.chip_count += player_bet
          puts "You lost $#{player_bet} for this hand"
          #skips to "do you want to play again??"
        end
      elsif player.is_natural_21?
        show_all_cards
        puts "You have a Blackjack.  You win this hand!"
        player.chip_count += player_bet
        dealer.chip_count -= player_bet
        puts "You won $#{player_bet} for this hand"
        #skips to "do you want to play again??"
      end

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

      if player.is_busted?
        puts "You have busted. You lose this hand!"
        player.chip_count -= player_bet
        dealer.chip_count += player_bet
        puts "You lost $#{player_bet} for this hand"
        show_all_cards
      else
          if dealer.get_count.first < 17
            begin
              show_all_cards
              dealer.add_card(deck.deal_card)
              sleep 0.5
            end until dealer.get_count.first > 16
          end

          if dealer.is_busted?
            show_all_cards
            puts "Dealer has busted. You win this hand!"
            puts "You won $#{player_bet} for this hand"
            player.chip_count += player_bet
            dealer.chip_count -= player_bet
          elsif player.get_count.last > dealer.get_count.last
            show_all_cards
            puts "You have #{player.get_count} and dealer has #{dealer.get_count}."
            puts "You win $#{player_bet} for this hand"
            player.chip_count += player_bet
            dealer.chip_count -= player_bet
          elsif player.get_count.last < dealer.get_count.last
            show_all_cards
            puts "You have #{player.get_count} and dealer has #{dealer.get_count}."
            puts "You lose $#{player_bet} for this hand"
            player.chip_count -= player_bet
            dealer.chip_count += player_bet
          end
      end

      puts "Your current chip count: $#{player.chip_count}"
      puts "Do you want to play more hands? y/n"
      play_again = gets.chomp
    end until play_again != "y"
  end
end

game = Blackjack.new()
game.new_game




