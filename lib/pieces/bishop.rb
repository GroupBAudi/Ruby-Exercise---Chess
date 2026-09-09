require_relative '../pieces'
require_relative '../helpers/board_parser'

# Holds all logic to Bishop including moving in diagonal lines to capture
# True to politics, Bishop simply take Rook's R&D and rotated it 45 degrees
class Bishop < Piece
  DIRECTIONS = [
    [1, 1], # diagonal right down
    [-1, 1], # diagonal right up
    [1, -1], # diagonal left down
    [-1, -1] # diagonal left up
  ]

  attr_reader :color, :symbol, :default_position
  attr_accessor :current_pos, :last_pos

  include BoardParser

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

  def valid_moves(board)
    x, y = @current_pos
    moves = []

    DIRECTIONS.each do |dx, dy|
      i = 1
      while within_boundary?(x + i * dx, y + i * dy, board) && empty?(x + i * dx, y + i * dy, board)
        
        new_x = x + i * dx
        new_y = y + i * dy      

        moves << [new_x, new_y]
        i += 1
      end
    end
    moves
  end
  
  def valid_capture_moves(board)
    x, y = @current_pos
    moves = []

    DIRECTIONS.each do |dx, dy|
      i = 1
      while within_boundary?(x + i * dx, y + i * dy, board) 
        new_x = x + i * dx
        new_y = y + i * dy      
        if !empty?(x + i * dx, y + i * dy, board) && opponent_piece?(x + i * dx, y + i * dy, board)
          moves << [new_x, new_y]
          break
        end
        break if !empty?(x + i * dx, y + i * dy, board) && !opponent_piece?(x + i * dx, y + i * dy, board)
        i += 1
      end
    end
    moves
  end

  def available_moves(board)
    array = valid_moves(board) + valid_capture_moves(board)
    moves = {}
    array.each_with_index { |cell, i| moves[i] = cell }
    moves
  end
end
