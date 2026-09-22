require_relative '../pieces'
require_relative '../helpers/board_parser'

# Holds all logic to King including moving in one direction, the ability to get checked, and castling
# Like a good king would, he took Queen's movement pattern and botched it so hard despite being the king
# He should watch more manosphere videos, or use T-90 gambit
class King < Piece
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
  attr_accessor :current_pos, :castle, :check, :last_pos

  include BoardParser

  def initialize(color, position)
    super(color, position) # calls Piece#initialize
    @current_pos = position
    @symbol = color == :white ? "♔" : "♚"
    @default_position = color == :white ? [7, position[1]] : [0, position[1]]
    @last_pos = []
    @check = false
    # @castle = false
  end

  def within_boundary?(row, col, board)
    row.between?(0, board.grid.length - 1) && col.between?(0, board.grid.length - 1)
  end

  def valid_moves(board)
    x, y = @current_pos
    moves = []

    DIRECTIONS.each do |dx, dy|
      new_x = x + dx
      new_y = y + dy      

      moves << [new_x, new_y] if within_boundary?(x + dx, y + dy, board) && empty?(x + dx, y + dy, board)
    end
    moves
  end

  def valid_capture_moves(board)
    x, y = @current_pos
    moves = []

    DIRECTIONS.each do |dx, dy|
      new_x = x + dx
      new_y = y + dy      

      if !empty?(x + dx, y + dy, board) && opponent_piece?(x + dx, y + dy, board)
        moves << [new_x, new_y]
        next
      end

      next if !empty?(x + dx, y + dy, board) && !opponent_piece?(x + dx, y + dy, board)
    end
    moves
  end

  def empty?(row, col, board)
     # we dont need to check row 8, -1, column -1. 8 etc
    return false unless row.between?(0, 7) && col.between?(0, 7)

    board.grid[row][col].nil?
  end

  def opponent_piece?(row, col, board)
    return false unless row.between?(0, 7) && col.between?(0, 7)
    
    board.grid[row][col].color != @color
  end
  
  # def after_move(board)
  #   # do stuff after something move i.e. pawn move for en passant, king move after checked expires castling
  # end

  # def expire_move_state
  # end
end
