require_relative '../pieces'
require_relative '../helpers/board_parser'
require_relative '../helpers/sliding_movement'

# Holds all logic to Rook including moving in straight lines including capture, and castling
class Rook < Piece
  DIRECTIONS = [
    [1, 0], # moves down
    [0, 1], # moves right
    [-1, 0], # moves up
    [0, -1] # moves left
  ]

  attr_reader :color, :symbol, :default_position
  attr_accessor :current_pos, :castle, :last_pos

  include BoardParser, SlidingMovement

  def initialize(color, position)
    super(color, position) # calls Piece#initialize
    @current_pos = position
    @symbol = color == :white ? "♖" : "♜"
    @default_position = color == :white ? [7, position[1]] : [0, position[1]]
    @last_pos = []
    @castle = true
  end
  
  def after_move(board)
    # do stuff after something move i.e. pawn move for en passant, king move after checked expires castling
    @castle = false
  end
end
