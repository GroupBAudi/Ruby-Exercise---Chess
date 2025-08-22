require_relative '../pieces'
require_relative '../board'

# Holds all logic to pawn including forward movement, diagonal capture, en passant, promotions
# Can move two pieces if hasn't moved yet
class Pawn < Piece
  PAWN_MOVES = {
    special_move: [[0, 2]],
    move: [[0, 1]],
    capture: [[-1, 1], [1, 1]]
  }

  attr_accessor :current_pos
  attr_reader :color
  # attr_reader :current_pos, :color

  def initialize(color, symbol = "♟", position = [0, 0])
    super(color, symbol, position) # calls Piece#initialize
    @current_pos = position
  end

  # checks available moves based on the board to prevent collision
  def valid_moves(position, board)
    x, y = position
    direction = @color == 'white' ? 1 : -1
    moves = []

    PAWN_MOVES.each do |key, value|
      next if key == :special_move && position != @current_pos
      next if key == :capture

      value.each do |dx, dy|    
        new_x = x + dx
        new_y = y + dy * direction

        # should be between current_position at board to max board row and column
        if new_x.between?(0, board.grid.length - 1) && new_y.between?(0, board.grid.length - 1)
          moves << [new_x, new_y]
        end
      end
    end
    moves
  end
  
  def valid_capture_moves(position, board)
    # returns true when there's nothing to capture
    x, y = position
    direction = @color == 'white' ? 1 : -1
    captures = []
    
    PAWN_MOVES[:capture].any? do |dx, dy|
      new_x = x + dx
      new_y = y + dy

      next unless new_x.between?(0, board.grid.length - 1) && new_y.between?(0, board.grid.length - 1)

      target = board.grid[new_x][new_y]
      if target && target.color != @color
        captures << [new_x, new_y]
      end
    end
    captures
  end

  def available_moves(position, board)
    array = valid_moves(position, board) + valid_capture_moves(position, board)
    moves = {}
    i = 0

    array.each_with_index do |cell, i|
      moves[i] = cell.flatten
    end

    moves
  end

  def moves(position, board)
    puts "Moves available:"
    options = available_moves(position, board)
    puts "Pick your move: "
    @current_pos = options[player_input]
  end

  def player_input
    loop do
      user_input = gets.chomp
      return user_input.to_i if user_input.match?(/^\d+$/)

      puts "Invalid move"
    end
  end
end

#   0 1 2 3 4 5 6 7 
#  brevity brevity
# 3 · · · · · · · ·
# 2 . . ♙ · · · · ·
# 1 . ♙ · · · · · ·
# 0 . . . . . . . .

# me when primitive debugging

# white = Pawn.new('white')
# black = Pawn.new('black')
# board = Board.new
# position_white = [1, 1]
# board.grid[2][2] = black
# p white.available_moves(position_white, board) 
# white.moves(position_white, board)
# p white.current_pos

