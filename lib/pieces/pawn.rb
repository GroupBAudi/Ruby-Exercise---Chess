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
    x = @current_pos[0]
    last_x = @last_pos.last[0]
    moved_two_step = last_x == start_row && (x - last_x).abs == 2

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

  def en_passant_capture_position(to)
    # to get the coord behind the advancing pawn after executing enpassant
    direction = color == :white ? 1 : -1
    target_row, target_col = to

    [target_row + direction, target_col]
  end

  def after_move(board)
    # do stuff after something move i.e. pawn move for en passant, king move after checked expires castling
    en_passant?(board)
  end

  def expire_move_state
    self.en_passant = false
  end
end
