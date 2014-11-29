# Symon He
# November 27, 2014
# Tealeaf Lesson 2 Assignment 2: OOP_TicTacToe1.rb

WINNING_LINES = [[1,2,3], [4,5,6], [7,8,9],[1,4,7], [2,5,8],[3,6,9],[1,5,9],[3,5,7]]
CORNERS = [1,3,7,9]

def num_is_float?(num_string)
  !(num_string !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/)
end

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
    end until available_moves.include?(user_next_move.to_i) && num_is_float?(user_next_move)
    user_next_move.to_i
  end

end

class Computer < Player

  def next_move(human_moves, available_moves)
    choice = 0

    defense_moves = human_moves.sort.combination(2).to_a.product(WINNING_LINES).collect {|x,y| (y-x) if (y-x).count ==1}.compact.flatten
    attack_moves = self.moves.sort.combination(2).to_a.product(WINNING_LINES).collect {|x,y| (y-x) if (y-x).count ==1}.compact.flatten

    if !(attack_moves & available_moves).empty?
      choice = (attack_moves & available_moves).sample
    elsif !(defense_moves & available_moves).empty?
      choice = (defense_moves & available_moves).sample
    elsif available_moves.include?(5)
      choice = 5
    elsif ((CORNERS & available_moves).count == 2) & (self.moves.count == 1) & ((self.moves & CORNERS).count == 0)
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
        self.board[i] = value
      else
        self.board[i] = i
      end
    end
  end

  def add_to_board(nextmove, symbol)
    self.board[nextmove] = symbol
  end

  def win_line_exists?
    if WINNING_LINES.find {|l| l.all? {|k| board[k] == self.human.symbol} }
      puts "You Win!"
      true
    elsif WINNING_LINES.find {|l| l.all? {|k| board[k] == self.computer.symbol} }
      puts "Sorry, you lose."
      true
    end
  end

  def print_board
    system("clear")
    puts "     |     |     "
    puts "  #{self.board[1]}  |  #{self.board[2]}  |  #{self.board[3]}"
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{self.board[4]}  |  #{self.board[5]}  |  #{self.board[6]}"
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{self.board[7]}  |  #{self.board[8]}  |  #{self.board[9]}"
    puts "     |     |     "
  end


  def start_game

    loop do
      self.human.moves = []
      self.computer.moves = []
      @available_moves = [1,2,3,4,5,6,7,8,9]
      @board = {}

      self.assign_board_value(false)
      self.print_board
      puts "Hello #{human.name}.  You are playing against #{computer.name}"
      self.assign_board_value("-")

      begin
        if (self.board.values.select {|v| v == "-"}.count == 1)
          user_next_move = available_moves.last
          self.add_to_board(user_next_move.to_i, self.human.symbol)
          self.human.moves.push(user_next_move.to_i)
        else
          user_next_move = self.human.next_move(self.available_moves)

          self.add_to_board(user_next_move.to_i, self.human.symbol)
          self.available_moves.delete(user_next_move.to_i)
          self.human.moves.push(user_next_move.to_i)
          self.print_board

          comp_next_move = computer.next_move(self.human.moves, self.available_moves)
          self.add_to_board(comp_next_move, self.computer.symbol)
          self.available_moves.delete(comp_next_move)
          self.computer.moves.push(comp_next_move)
        end

        sleep 0.25
        self.print_board

        if (self.board.values.select {|v| v == "-"}.count < 1)
          puts "You Tie!"
          gameover = true
        else
          gameover = self.win_line_exists?
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



