# Symon He
# November 30, 2014
# Tealeaf Lesson 2 Assignment 2: OOP_TicTacToe2.rb

WINNING_LINES = [[1,2,3], [4,5,6], [7,8,9],[1,4,7], [2,5,8],[3,6,9],[1,5,9],[3,5,7]]
CORNERS = [1,3,7,9]

class Player
  attr_accessor :name, :moves, :symbol

  def initialize(name, symbol)
    @name = name
    @symbol = symbol
    @moves = []
  end
end

class Human < Player

  def next_move(available_moves)
    begin
      puts "Enter your move from what is available: #{available_moves.join(", ")}"
      user_next_move = gets.chomp
    end until available_moves.include?(user_next_move.to_i)
    user_next_move.to_i
  end
end

class Computer < Player

  def next_move(human_moves, available_moves)
    choice = 0

    defense_moves = human_moves.sort.combination(2).to_a.product(WINNING_LINES).collect {|x,y| (y-x) if (y-x).count ==1}.compact.flatten
    attack_moves = moves.sort.combination(2).to_a.product(WINNING_LINES).collect {|x,y| (y-x) if (y-x).count ==1}.compact.flatten

    if !(attack_moves & available_moves).empty?
      choice = (attack_moves & available_moves).sample
    elsif !(defense_moves & available_moves).empty?
      choice = (defense_moves & available_moves).sample
    elsif available_moves.include?(5)
      choice = 5
    elsif ((CORNERS & available_moves).count == 2) & (moves.count == 1) & ((moves & CORNERS).count == 0)
      choice = (CORNERS & available_moves).sample + 1 if (CORNERS & available_moves).sample < 8
    elsif !(CORNERS & available_moves).empty?
      (CORNERS & available_moves).each do |x|
        if (human_moves.include?(x - 1) || human_moves.include?(x +1))
          choice = x
        else
          choice = (CORNERS & available_moves).sample
        end
      end
    else
      choice = available_moves.sample
    end
    return choice
  end
end

class TicTacToe
  attr_accessor :available_moves, :board, :human, :computer

  def initialize(human, computer)
    @human = Human.new(human, "X")
    @computer = Computer.new(computer, "O")
  end

  def update_available_moves(human_moves, computer_moves)
    @available_moves = @available_moves - human_moves - computer_moves
  end

  def assign_board_value(value)
    for i in 1..9
      if value
        board[i] = value
      else
        board[i] = i
      end
    end
  end

  def add_to_board(nextmove, symbol)
    board[nextmove] = symbol
  end

  def win_line_exists?
    if WINNING_LINES.find {|l| l.all? {|k| board[k] == human.symbol} }
      puts "You Win!"
      true
    elsif WINNING_LINES.find {|l| l.all? {|k| board[k] == computer.symbol} }
      puts "Sorry, you lose."
      true
    end
  end

  def print_board
    system("clear")
    puts "     |     |     "
    puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}"
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}"
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}"
    puts "     |     |     "
  end

  def start_game

    loop do
      human.moves = []
      computer.moves = []
      @available_moves = [1,2,3,4,5,6,7,8,9]
      @board = {}

      assign_board_value(false)
      print_board
      puts "Hello #{human.name}.  You are playing against #{computer.name}"
      assign_board_value("-")

      begin
        if (board.values.select {|v| v == "-"}.count == 1)
          user_next_move = available_moves.last
          add_to_board(user_next_move.to_i, human.symbol)
          human.moves.push(user_next_move.to_i)
        else
          user_next_move = human.next_move(available_moves)

          add_to_board(user_next_move.to_i, human.symbol)
          available_moves.delete(user_next_move.to_i)
          human.moves.push(user_next_move.to_i)
          print_board

          comp_next_move = computer.next_move(human.moves, available_moves)
          add_to_board(comp_next_move, computer.symbol)
          available_moves.delete(comp_next_move)
          computer.moves.push(comp_next_move)
        end

        sleep 0.25
        print_board

        if (board.values.select {|v| v == "-"}.count < 1)
          puts "You Tie!"
          gameover = true
        else
          gameover = win_line_exists?
        end

      end until gameover

      puts "Do you want to play again? y/n."
      break if gets.chomp.downcase != 'y'
    end
  end
end

puts "What is your name?"
name = gets.chomp
game = TicTacToe.new(name, "R2D2")
game.start_game



