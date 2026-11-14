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
    @castle = true
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

  def expire_move_state
    self.castle = false
  end

  def valid_castle_moves(board)
    king_row, king_col = self.current_pos
    moves = []

    board.grid[king_row].each do |coor|
      next unless coor.is_a?(Rook)

      # if king's direction to is under attack then it can't castle
      # temporarily store king state in certain direction, and see for check
      # if check reject it

      if coor.castle && self.castle
        if coor.current_pos[1] < king_col && !board.piece_under_attack?([king_row, king_col - 1], self.color) && !board.piece_under_attack?([king_row, king_col - 2], self.color)
          moves << [king_row, king_col - 2]
        elsif coor.current_pos[1] > king_col && !board.piece_under_attack?([king_row, king_col + 1], self.color) && !board.piece_under_attack?([king_row, king_col + 2], self.color)
          moves << [king_row, king_col + 2]
        end
      end
    end

    moves
  end

  def castle_move(board, destination)
    col = @current_pos[1]
    destination_row, destination_col = destination

    board.place_piece(@current_pos, destination, self)

    if destination[1] < col
      rook = board.grid[destination_row][destination_col - 2]
      board.place_piece(rook.current_pos, [destination_row, destination_col + 1], rook)
    elsif destination[1] > col
      rook = board.grid[destination_row][destination_col + 1]
      board.place_piece(rook.current_pos, [destination_row, destination_col - 1], rook)
    end
    expire_move_state
  end

  def universal_moves(board)
    super + valid_castle_moves(board)
  end

  def special_move(board, to)
    return nil unless valid_castle_moves(board).include?(to)

    castle_move(board, to)
  end
end
