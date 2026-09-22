require_relative '../pieces'
require_relative '../helpers/board_parser'
require_relative '../helpers/sliding_movement'

# Holds all logic to Bishop including moving in diagonal lines to capture
# <s>True to politics, Bishop simply take Rook's R&D and rotated it 45 degrees</s>
# At least its now been outsourced from shared module

class Bishop < Piece
  DIRECTIONS = [
    [1, 1], # diagonal right down
    [-1, 1], # diagonal right up
    [1, -1], # diagonal left down
    [-1, -1] # diagonal left up
  ]

  attr_reader :color, :symbol, :default_position
  attr_accessor :current_pos, :last_pos

  include BoardParser, SlidingMovement

  def initialize(color, position)
    super(color, position) # calls Piece#initialize
    @current_pos = position
    @symbol = color == :white ? "♗" : "♝"
    @default_position = color == :white ? [7, position[1]] : [0, position[1]]
    @last_pos = []
  end

  def within_boundary?(row, col, board)
    row.between?(0, board.grid.length - 1) && col.between?(0, board.grid.length - 1)
  end

  def empty?(row, col, board)
    board.grid[row][col].nil?
  end

  def opponent_piece?(row, col, board)
    board.grid[row][col].color != @color
  end
end
