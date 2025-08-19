require_relative '../pieces'
require_relative '../board'

# Holds all logic to pawn including forward movement, diagonal capture, en passant, promotions
# Can move two pieces if hasn't moved yet
class Pawn < Piece
  PAWN_MOVES = {
    special_move: [[0, 2]],
    move: [[0, 1]],
    capture: [[1, 1], [-1, 1]]
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
    moves = []

    PAWN_MOVES.each do |key, value|
      next if key == :special_move && position != @current_pos
      
      value.each do |dx, dy|
        new_x = x + dx
        new_y = y + dy * direction

        # should be between current_position at board to max board row and column
        moves << [new_x, new_y] if new_x.between?(0, board.grid.length - 1) && new_y.between?(0, board.grid.length - 1)
      end
    end
    moves
  end

  def bfs(start, target)
    bfs(start, target)
  end

  def moves(start, target, position)
    # use a queue to explore positions
    # track visited squares
    # store parent relationships to reconstruct path
  end

  def build_path(parent, target)
    # reconstruct path from start to target using parent's hash
  end
end
