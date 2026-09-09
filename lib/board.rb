require_relative 'pieces'
require_relative 'pieces/pawn'
require_relative 'pieces/rook'
require_relative 'pieces/bishop'
require_relative 'helpers/renderer'

# Holds all logic related to positioning and collisions
class Board
  attr_reader :grid
  attr_accessor :removed_piece, :move_history

  include Renderer

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    @move_history = []
  end

  def setup_pieces
    # initialize pieces
    # white and black pawns as well as super pieces 

    # setup pawns
    # (0..7).each do |col|
    #   @grid[6][col] = Pawn.new(:white, [6, col])
    #   @grid[1][col] = Pawn.new(:black, [1, col])
    # end
  
    # skeleton in closet:
    @grid[0][2] = Bishop.new(:black, [0, 2])
    @grid[0][5] = Bishop.new(:black, [0, 5])
    @grid[7][2] = Bishop.new(:white, [7, 2])
    @grid[7][5] = Bishop.new(:white, [7, 5])

    [0, 7].each do |col| 
      @grid[7][col] = Rook.new(:white, [7, col])
      @grid[0][col] = Rook.new(:black, [0, col])
    end
  end

  def move_piece(from, to)
    piece = piece_at(from)
    return nil unless piece

    move_to(from, to, piece)
  end

  def capturing_condition(to)
    target = piece_at(to)
    !target.nil?
  end

  def move_to(from, to, piece)
    special_capture = piece.special_capture_position(self, to)
    if capturing_condition(to)
      # if piece exists and target is occupied
      capture(from, to, piece)
    elsif special_capture
      # if piece is a pawn and has en passant move available
      capture(from, to, piece, special_capture)
    else
      # just place piece if anything
      place_piece(from, to, piece)
      nil # returns nil because nothing is captured
    end
  end

  def piece_at(position) # getter
    # What occupies this square?
    x, y = position
    @grid[x][y]
  end

  def set_piece_at(position, value) # setter
    # Put this value on this square
    x, y = position
    @grid[x][y] = value
  end

  def remove_piece(position)
    # Remove and return what's on this square
    piece = piece_at(position)
    set_piece_at(position, nil)
    piece
  end

  def add_history(piece, current_position, target)
    @move_history << {
      piece: piece,
      from: current_position,
      to: target
    }
  end

  def expire_move_state
    return if @move_history.length < 2

    previous_piece = @move_history[-2][:piece]
    previous_piece.expire_move_state
  end

  def place_piece(from, to, piece)
    target_row, target_col = to
    piece.last_pos << piece.current_pos
    add_history(piece, piece.current_pos, to)
    set_piece_at(to, piece)
    set_piece_at(from, nil)
    piece.current_pos = [target_row, target_col]
    # flag a pawn with en passant if moving pawn class
    piece.after_move(self)
    # expire en passant if opportunity wasted
    expire_move_state
  end

  def capture(from, to, piece, capture_position = to)
    # move piece from from to to, while removing the piece at capture_position
    # where unless en passant, remove the occuppying grid on opponent piece pos
    target = remove_piece(capture_position)
    place_piece(from, to, piece)
    target
  end
end

board = Board.new

board.setup_pieces

puts ""

# main
board.grid[4][7] = Bishop.new(:white, [4, 7])

# # ally test
# board.grid[1][4] = Bishop.new(:white, [1, 4])
# # enemy test
# board.grid[6][2] = Bishop.new(:black, [6, 2])
# board.grid[6][6] = Bishop.new(:black, [6, 6])
# board.grid[2][2] = Bishop.new(:black, [2, 2])
# board.grid[2][6] = Bishop.new(:black, [2, 6])


x = board.piece_at([4, 7])

board.render

p x.valid_moves(board)
# p x.valid_capture_moves(board)
# p x.available_moves(board)
