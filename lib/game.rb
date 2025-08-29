require_relative 'board'
require_relative 'player'

class Game
  attr_reader :board
  attr_accessor :current_player

  def initialize(board = Board.new)
    @board = board
    @player_one = Player.new("Player one", :white)
    @player_two = Player.new("Player two", :black)
    @current_player = @player_one
    @board.setup_pieces
  end

  def swap_turn
    @current_player = (@current_player == @player_one) ? @player_two : @player_one
  end

  def correct_player_piece?(row, col)
    @current_player.color == @board.grid[row.to_i][col.to_i].color
  end

  def check_row(row)
    @board.grid[row].none? { |col| col.nil? }
  end

  def player_input_row
    loop do
      row_input = gets.chomp
      return row_input if row_input.match?(/^\d+$/) && check_row(row_input.to_i)
      
      puts "Enter a valid input from 0 to #{board.grid.length - 1}"
    end
  end

  def player_input_col(row)
    loop do
      col_input = gets.chomp
      return col_input if col_input.match(/^\d+$/) && @board.grid[row][col_input.to_i]

      puts "Enter a valid input from 0 to #{board.grid[0].length - 1}"
    end
  end

  def player_input
    loop do
      puts "Choose row"
      row = player_input_row
      puts "You picked #{row} as row"
      puts "Choose column"
      col = player_input_col(row.to_i)
      puts "You picked #{col} as column"

      return [row, col] if correct_player_piece?(row, col)
      puts "Rejected. Current player is #{@current_player.name} as #{@current_player.color}"
    end
  end

  def play_turn
    @board.render
    piece = get_piece(player_input)
    available_moves = show_available_moves(piece)
    puts "Choose move"
    puts available_moves
    player_input = gets.chomp
    move_piece(available_moves, piece, player_input)
    @board.render
    swap_turn
  end

  def get_piece(player_input)
    row, col = player_input
    board.grid[row.to_i][col.to_i]
  end

  def show_available_moves(piece)
    piece.available_moves(@board)
  end

  def move_piece(available_moves, piece, player_input)
    move_chosen = available_moves[player_input.to_i]
    @board.move_piece(piece.current_pos, move_chosen)
  end
end

game = Game.new
game.play_turn
