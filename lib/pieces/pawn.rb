require_relative '../pieces'
require_relative '../helpers/board_parser'

# Holds all logic to pawn including forward movement, diagonal capture, en passant, promotions
# Can move two pieces if hasn't moved yet
class Pawn < Piece
  PAWN_MOVES = {
    move: [[1, 0]],
    capture: [[1, -1], [1, 1]]
  }

  attr_reader :color, :symbol, :default_position
  attr_accessor :current_pos, :en_passant, :last_pos

  include BoardParser

  def initialize(color, position)
    super(color, position) # calls Piece#initialize
    @current_pos = position
    @symbol = color == :white ? "♙" : "♟"
    @default_position = color == :white ? [6, position[1]] : [1, position[1]]
    @last_pos = []
    @en_passant = false
  end

  def within_boundary?(row, col, board)
    row.between?(0, board.grid.length - 1) && col.between?(0, board.grid.length - 1)
  end

  def check_collision?(row, col, two_step, board)
    board.grid[row][col].nil? && board.grid[two_step][col].nil?
  end

  def valid_moves(board)
    x, y = @current_pos
    direction = @color == :white ? -1 : 1
    moves = []

    PAWN_MOVES[:move].each do |dx, dy|
      new_x = x + dx * direction
      new_y = y + dy 

      next unless within_boundary?(new_x, new_y, board)

      two_step = x + (2 * direction)
      
      if @current_pos == @default_position && check_collision?(new_x, new_y, two_step, board)
        moves << [two_step, new_y]
      end

      next unless board.grid[new_x][new_y].nil?
      moves << [new_x, new_y]
    end
    moves
  end
  
  def valid_capture_moves(board)
    # return an array if there is a piece(s) diagonally
    x, y = @current_pos
    direction = @color == :white ? -1 : 1
    captures = []
    
    PAWN_MOVES[:capture].each do |dx, dy|
      new_x = x + dx * direction
      new_y = y + dy 

      next unless within_boundary?(new_x, new_y, board)

      target = board.grid[new_x][new_y]
      condition = target && target.color != @color
      if condition
        captures << [new_x, new_y]
      end
    end
    captures
  end

  def available_moves(board)
    array = valid_moves(board) + valid_capture_moves(board) + valid_en_passant_move(board)
    moves = {}
    array.each_with_index { |cell, i| moves[i] = cell }
    moves
  end

  def en_passant?(board)
    start_row = @default_position[0]
    x, y = @current_pos
    last_x, last_y = @last_pos.last
    moved_two_step = last_x == start_row && (x - last_x).abs == 2
    
    p @last_pos.last

    if moved_two_step
      @en_passant = true
    else
      @en_passant = false
    end
  end

  def valid_en_passant_move(board)
    x, y = @current_pos
    move = []

    [-1, 1].each do |dy|
      neighbor = board.grid[x][y + dy] rescue nil
      if neighbor.is_a?(Pawn) && neighbor.en_passant
        move << [x + (@color == :white ? -1 : 1), y + dy]
      end
    end

    move
  end
end

# require_relative '../board'

# board = Board.new

# position_white = [6, 1]
# white_pawn = Pawn.new(:white, position_white)
# wx, wy = position_white
# board.grid[wx][wy] = white_pawn
# white_pawn.last_pos << position_white

# board.render
# puts ""

# white_pawn.last_pos << position_white
# board.grid[wx][wy] = nil
# position_white = [4, 1]
# wx, wy = position_white
# board.grid[wx][wy] = white_pawn
# white_pawn.current_pos = position_white

# board.render
# puts ""

# board.grid[wx][wy] = nil
# position_white = [3, 1]
# wx, wy = position_white
# board.grid[wx][wy] = white_pawn
# white_pawn.current_pos = position_white

# board.render
# puts ""

# position_black = [1, 2]
# black_pawn = Pawn.new(:black, position_black)
# bx, by = position_black
# board.grid[bx][by] = black_pawn

# board.render
# puts ""

# black_pawn.last_pos << position_black
# board.grid[bx][by] = nil
# position_black = [3, 2]
# bx, by = position_black
# board.grid[bx][by] = black_pawn
# black_pawn.current_pos = position_black

# board.render
# # stubs black pawn
# p black_pawn.en_passant?(board) # true
# p white_pawn.available_moves(board)
# puts ""

# board.render
# p white_pawn.valid_moves(board)

# position_black = [5, 1]
# bx, by = position_black
# board.grid[bx][by] = Pawn.new(:black, position_black)
# black_pawn = board.grid[bx][by]

# board.render
# p white_pawn.valid_moves(board)

# board.grid[bx][by] = nil

# position_black = [4, 1]
# bx, by = position_black
# board.grid[bx][by] = Pawn.new(:black, position_black)
# black_pawn = board.grid[bx][by]

# board.render
# p white_pawn.valid_moves(board)
# board.grid[bx][by] = nil

# position_black = [3, 1]
# bx, by = position_black
# board.grid[bx][by] = Pawn.new(:black, position_black)
# black_pawn = board.grid[bx][by]

# board.render
# p white_pawn.valid_moves(board)

# black version

# position_white = [4, 1]
# wx, wy = position_white
# board.grid[wx][wy] = Pawn.new(:white, position_white)
# white_pawn = board.grid[wx][wy]

# position_black = [3, 1]
# bx, by = position_black
# board.grid[bx][by] = Pawn.new(:black, position_black)
# black_pawn = board.grid[bx][by]

# board.render
# p black_pawn.valid_moves(board)

# board.grid[wx][wy] = nil

# position_white = [5, 1]
# wx, wy = position_white
# board.grid[wx][wy] = Pawn.new(:white, position_white)
# white_pawn = board.grid[wx][wy]

# board.render
# p black_pawn.valid_moves(board)
# board.grid[wx][wy] = nil

# position_white = [6, 1]
# wx, wy = position_white
# board.grid[wx][wy] = Pawn.new(:white, position_white)
# white_pawn = board.grid[wx][wy]

# board.render
# p black_pawn.valid_moves(board)
