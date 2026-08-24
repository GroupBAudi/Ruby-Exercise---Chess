require_relative 'pieces'
require_relative 'pieces/pawn'
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
    if capturing_condition(to)
      # if piece exists and target is occupied
      capture(from, to, piece)
    elsif piece.is_a?(Pawn) && piece.valid_en_passant_move(self) == [to]
      # if piece is a pawn and has en passant move available
      en_passant_capture(from, to, piece)
    else
      # just place piece if anything
      place_piece(from, to, piece)
      nil # returns nil because nothing is captured
    end
  end

  def piece_at(position) # getter
    x, y = position
    @grid[x][y]
  end

  def set_piece_at(position, value) # setter
    x, y = position
    @grid[x][y] = value
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

  def capture(from, to, piece)
    target = piece_at(to)

    set_piece_at(to, nil)
    place_piece(from, to, piece)

    # return the dead piece to whoever asked for the move
    target
  end

  def en_passant_capture(from, to, piece)
    target_coord = piece.en_passant_capture_position(to)

    dead_pawn = piece_at(target_coord)
    set_piece_at(target_coord, nil)
    place_piece(from, to, piece)

    dead_pawn
  end
end

# board = Board.new

# board.setup_pieces
# board.render

# puts ""

# # seperator piggies certified OSHA more like Oink-SHA ##

# # white
# board.move_piece([6, 1], [4, 1])
# # black
# board.move_piece([1, 2], [3, 2])
# # white
# board.move_piece([4, 1], [3, 1])
# # black
# board.move_piece([1, 0], [3, 0])
# board.render
# puts ""

# white = board.piece_at([3, 1])
# # black = board.piece_at([3, 2])
# # p white.available_moves(board)
# p white.valid_en_passant_move(board)
