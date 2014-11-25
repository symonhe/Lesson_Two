# Symon He
# November 7, 2014
# Tealeaf Lesson 2 Assignment 1: OOP_PRS3.rb

class Player
  attr_accessor :name, :choice
  def initialize(n)
    @name = n
    @choice =" "
  end
end

class User < Player
  def get_user_choice
    begin
      puts "Type P, R, or S.  Pick one."
      self.choice = gets.chomp.downcase
    end until ["p", "r", "s"].include?(self.choice)
  end
end

class Computer < Player
  def get_comp_choice
    self.choice = ["p","r","s"].sample
  end
end

class Paper_Rock_Scissor
  CHOICES = {'p' => "Paper", 'r' => "Rock", 's' => "Scissors"}

  attr_accessor :player, :computer

  def initialize
    @player = User.new("Player")
    @computer = Computer.new("Computer")
  end

  def print_result(player_hand, computer_hand)
    puts "You chose #{player_hand}, Computer chose #{computer_hand}."

    case
    when player_hand == computer_hand then puts "----You tie!----"
    when (player_hand == "p" && computer_hand == "r") then puts "----#{CHOICES[player_hand]} covers #{CHOICES[computer_hand]}. You win!----"
    when (player_hand == "p" && computer_hand == "s") then puts "----#{CHOICES[computer_hand]} cut #{CHOICES[player_hand]} . You lose.----"
    when (player_hand == "r" && computer_hand == "p") then puts "----#{CHOICES[computer_hand]} covers #{CHOICES[player_hand]}. You lose.----"
    when (player_hand == "r" && computer_hand == "s") then puts "----#{CHOICES[player_hand]} crushes #{CHOICES[computer_hand]}. You win!----"
    when (player_hand == "s" && computer_hand == "r") then puts "----#{CHOICES[computer_hand]} crushes #{CHOICES[player_hand]}. You lose.----"
    when (player_hand == "s" && computer_hand == "p") then puts "----#{CHOICES[player_hand]} cut #{CHOICES[computer_hand]}. You win!----"
    end

  end

  def start_game
    begin
      player.get_user_choice
      computer.get_comp_choice

      print_result(player.choice, computer.choice)

      puts "Do you want to play again? (y/n)"
      again = gets.chomp.upcase

    end until (again != "Y")
  end

end

game = Paper_Rock_Scissor.new
game.start_game
