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

  attr_reader :current_pos, :color

  def initialize(color, symbol = "♟", position = [0, 0])
    super(color, symbol, position) # calls Piece#initialize
    @current_pos = position
  end

  # checks available moves based on the board to prevent collision
  def valid_moves(position, board)
    x, y = position
    direction = @color == 'white' ? 1 : -1
    moves = {}
    i = 0

    PAWN_MOVES.each do |key, value|
      next if key == :special_move && position != @current_pos
    
      value.each do |dx, dy|    
        new_x = x + dx
        new_y = y + dy * direction

        # should be between current_position at board to max board row and column
        if new_x.between?(0, board.grid.length - 1) && new_y.between?(0, board.grid.length - 1)
          moves[i] = [new_x, new_y] 
          i += 1
        end
      end
    end
    # make moves into hash
    moves
  end

  def available_moves(position, board)
    moves = valid_moves(position, board)
    moves.each do |k, v|
      puts "##{k}: #{v}"
    end
    moves
  end

  def moves(position, board)
    puts "Moves available:"
    available_moves
    puts "Pick your move: "
    @current_pos = moves[player_input]
  end

  def player_input
    loop do
      user_input = gets.chomp
      return user_input.to_i if user_input.match?(/^\d+$/)

      puts "Invalid move"
    end
  end
end
