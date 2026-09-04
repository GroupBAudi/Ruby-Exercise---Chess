require_relative '../pieces'
require_relative '../helpers/board_parser'

# Holds all logic to Rook including moving in straight lines including capture, and castling
class Rook < Piece
  attr_reader :color, :symbol, :default_position
  attr_accessor :current_pos, :castle, :last_pos

  include BoardParser

  def initialize(color, position)
    super(color, position) # calls Piece#initialize
    @current_pos = position
    @symbol = color == :white ? "♖" : "♜"
    @default_position = color == :white ? [7, position[1]] : [0, position[1]]
    @last_pos = []
    # @castle = false
  end

  def within_boundary?(row, col, board)
    row.between?(0, board.grid.length - 1) && col.between?(0, board.grid.length - 1)
  end

  def check_collision?(row, col, dx = 0, dy = 0, board)
    board.grid[row + dx][col + dy].nil?
  end

  def valid_moves(board)
    x, y = @current_pos
    moves = []

    # rook in [4, 4]
    # first index, loop from 0 to 7, if there are no obstruction, valid moves are from 0, 1, 2, 3, 5, 6, 7
    # second index, also same
    # if there are obstructions, stop there
    
    # horizontal
    i, hor_dir, hor_lim = 1, 1, 0
    hor_moves = []
    while (hor_lim <= 1 && y + i * hor_dir >= 0)
      if !within_boundary?(x, y + i * hor_dir, board) || !board.grid[x][y + i * hor_dir].nil? 
        # changes direction, increment limits, reset i value
        hor_dir = -1
        hor_lim += 1
        i = 1
        # GPT: skip the rest of the iteration and recheck the while condition
        next
      end
      # p "horizontal: #{[x, y + i * hor_dir]}"
      hor_moves << [x, y + i * hor_dir]
      i += 1
    end

    # vertical
    j, ver_dir, ver_lim = 1, 1, 0
    ver_moves = []
    while (ver_lim <= 1 && x + j * ver_dir >= 0)
      if !within_boundary?(x + j * ver_dir, y, board) || !board.grid[x + j * ver_dir][y].nil?
        # changes direction, increment limits, reset i value
        ver_dir = -1
        ver_lim += 1
        j = 1
        # skip the rest of the iteration and recheck the while condition
        next
      end
      # p "vertical: #{[x + j * ver_dir, y]}"
      ver_moves << [x + j * ver_dir, y]
      j += 1
    end
    moves << hor_moves
    moves << ver_moves
    moves
  end
  
  def valid_capture_moves(board)
    # borrow valid move algorithm
    # difference: if it collide then add as valid move
    
    x, y = @current_pos
    moves = []
    
    # horizontal
    i, hor_dir, hor_lim = 1, 1, 0
    hor_val_moves = []
    while (hor_lim <= 1 && y + i * hor_dir >= 0)
      if !within_boundary?(x, y + i * hor_dir, board)
        hor_dir = -1
        hor_lim += 1
        i = 1
        # skip the rest of the iteration and recheck the while condition
        next
      end

      if (!board.grid[x][y + i * hor_dir].nil? && board.grid[x][y + i * hor_dir].color == @color)
        hor_dir = -1
        hor_lim += 1
        i = 1
        next
      end

      if board.grid[x][y + i * hor_dir].is_a?(Piece) && board.grid[x][y + i * hor_dir].color != board.grid[x][y].color
        hor_val_moves << [x, y + i * hor_dir] 
        hor_dir = -1
        hor_lim += 1
        i = 1
      end
      i += 1
    end
    
    # vertical
    j, ver_dir, ver_lim = 1, 1, 0
    ver_val_moves = []
    while (ver_lim <= 1 && x + j * ver_dir >= 0)
      if !within_boundary?(x + j * ver_dir, y, board)
        # changes direction, increment limits, reset i value
        ver_dir = -1
        ver_lim += 1
        j = 1
        # skip the rest of the iteration and recheck the while condition
        next
      end

      if (!board.grid[x + j * ver_dir][y].nil? && board.grid[x + j * ver_dir][y].color == @color)
        ver_dir = -1
        ver_lim += 1
        j = 1
        next
      end

      if board.grid[x + j * ver_dir][y].is_a?(Piece) && board.grid[x + j * ver_dir][y].color != board.grid[x][y].color
        ver_val_moves << [x + j * ver_dir, y] 
        ver_dir = -1
        ver_lim += 1
        j = 1
        next
      end
      j += 1
    end
    moves << hor_val_moves
    moves << ver_val_moves
    moves
  end

  def available_moves(board)
    array = valid_moves(board) + valid_capture_moves(board)
    moves = {}
    array.each_with_index { |cell, i| moves[i] = cell }
    moves
  end

  # def after_move(board)
  #   # do stuff after something move i.e. pawn move for en passant, king move after checked expires castling
  # end

  # def expire_move_state
  # end
end
