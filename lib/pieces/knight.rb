require_relative '../pieces'
require_relative '../helpers/board_parser'

# Holds all logic to Knight with ability to move in an L-shaped pattern
# It can jump over their neigh-bors or foaling around. 
# My mane piece. We both have something in common with L

class Knight < Piece
  DIRECTIONS = [
    [2, 1], [-2, 1], [2, -1], [-2, -1],
    [1, 2], [-1, 2], [1, -2], [-1, -2]
  ]

  attr_reader :color, :symbol, :default_position
  attr_accessor :current_pos, :last_pos

  include BoardParser

  def initialize(color, position)
    super(color, position) # calls Piece#initialize
    @current_pos = position
    @symbol = color == :white ? "♘" : "♞"
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

  def iter(row, col, board)
    moves = []
    DIRECTIONS.each do |dx, dy|
      new_x = row + dx
      new_y = col + dy
      moves << [new_x, new_y] if within_boundary?(new_x, new_y, board)
    end
    moves
  end

  def valid_moves(board)
    x, y = @current_pos
    moves = iter(x, y, board).select do |curr_move|
      x, y = curr_move
      empty?(x, y, board)
    end
    
    moves
  end

  def valid_capture_moves(board)
    x, y = @current_pos
    moves = iter(x, y, board).select do |curr_move|
      x, y = curr_move
      !empty?(x, y, board) && opponent_piece?(x, y, board)
    end

    moves
  end

  def moves(board)
    x, y = @current_pos
    iter(x, y, board)
  end

  def available_moves(board)
    array = valid_moves(board) + valid_capture_moves(board)
    moves = {}
    array.each_with_index { |cell, i| moves[i] = cell }
    moves
  end
end
