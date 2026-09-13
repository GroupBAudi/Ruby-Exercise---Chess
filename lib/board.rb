require_relative 'pieces'
require_relative 'pieces/pawn'
require_relative 'pieces/rook'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/queen'
require_relative 'pieces/king'
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
    (0..7).each do |col|
      @grid[6][col] = Pawn.new(:white, [6, col])
      @grid[1][col] = Pawn.new(:black, [1, col])
    end
  
    # setup any other pieces
    (0..1).each_with_index do |x, i|
      i = 1
      i = -1 if x == 1
      @grid[7][(0 + x) * i] = Rook.new(:white, [7, (0 + x) * i])
      @grid[7][(1 + x) * i] = Knight.new(:white, [7, (1 + x) * i])
      @grid[7][(2 + x) * i] = Bishop.new(:white, [7, (2 + x) * i])
      @grid[0][(0 + x) * i] = Rook.new(:black, [0, (0 + x) * i])
      @grid[0][(1 + x) * i] = Knight.new(:black, [0, (1 + x) * i])
      @grid[0][(2 + x) * i] = Bishop.new(:black, [0, (2 + x) * i])
    end

    # setup king and queen because irl courtship doesn't work like that
    [0, 7].each do |i|
      x = :black
      x = :white if i == 7
      @grid[i][3] = Queen.new(x, [i, 3])
      @grid[i][4] = King.new(x, [i, 4])
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

board.render

puts ""

# # main
# board.grid[4][4] = King.new(:white, [4, 4])

# # horse-ing around
# board.grid[6][6] = Knight.new(:white, [6, 6])

# # ally test
# board.grid[4][5] = Bishop.new(:white, [4, 5])
# # enemy test
# board.grid[3][5] = Knight.new(:black, [3, 5])
# board.grid[5][3] = Pawn.new(:black, [5, 3])
# board.grid[5][5] = Queen.new(:black, [5, 5])
# board.grid[5][4] = Rook.new(:black, [5, 4])


# x = board.piece_at([4, 4])

# board.render

# p x.valid_moves(board)
# p x.valid_capture_moves(board)
# # p x.available_moves(board)
