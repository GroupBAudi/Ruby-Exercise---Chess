require_relative '../pieces'
require_relative '../helpers/board_parser'
require_relative '../helpers/sliding_movement'

# Holds all logic to Queen including moving in diagonal lines to capture
# <s>Now Queen does hostile takeover to both Bishop's and Rook's movement patterns.</s>
# At least it has been sourced from module
class Queen < Piece
  DIRECTIONS = [
    [1, 1], # diagonal right down
    [-1, 1], # diagonal right up
    [1, -1], # diagonal left down
    [-1, -1], # diagonal left up
    [1, 0], # moves down
    [0, 1], # moves right
    [-1, 0], # moves up
    [0, -1] # moves left
  ]

  attr_reader :color, :symbol, :default_position
  attr_accessor :current_pos, :last_pos

  include BoardParser, SlidingMovement

  def initialize(color, position)
    super(color, position) # calls Piece#initialize
    @current_pos = position
    @symbol = color == :white ? "♕" : "♛"
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

  def available_moves(board)
    array = valid_moves(board) + valid_capture_moves(board)
    moves = {}
    array.each_with_index { |cell, i| moves[i] = cell }
    moves
  end
end
