require_relative 'pieces'
require_relative 'pieces/pawn'
require_relative 'helpers/board_pawn_helper'

# Holds all logic related to positioning and collisions
class Board
  attr_reader :grid
  attr_accessor :removed_piece, :last_move

  include BoardPawnHelper

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    @last_move = []
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

  def move_piece(current_player, from, to)
    piece = piece_at(from)
    return "Move rejected" unless piece

    move_to(current_player, from, to, piece)
  end

  def move_to(current_player, from, to, piece)
    target = piece_at(to)

    if !target.nil?
      # if piece exists and target is occupied
      capture(from, to, piece, current_player)
    elsif piece.is_a?(Pawn) && piece.valid_enpassant_move(self) == [to]
      # if piece is a pawn and has en passant move available
      en_passant_capture(from, to, piece, current_player)
    else
      # just place piece if anything
      place_piece(from, to, piece)
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

  def place_piece(from, to, piece)
    target_row, target_col = to
    piece.last_pos << piece.current_pos
    @last_move << [piece.current_pos, to]
    set_piece_at(to, piece)
    set_piece_at(from, nil)
    piece.current_pos = [target_row, target_col]
    # flag a pawn with en passant if moving pawn class
    trigger_en_passant(piece, self) if piece.is_a?(Pawn)
  end

  def capture(from, to, piece, current_player)
    target = piece_at(to)
    current_player.captured_pieces << target
    set_piece_at(to, nil)
    place_piece(from, to, piece)
  end

  def render
    (1..8).to_a.reverse.each_with_index do |letter, i|
      break if i >= @grid.size
      print "#{letter} "
      row = @grid[i]
      puts row.map { |cell| cell.nil? ? "." : cell.symbol }.join(" ")
    end

    print "  "
    ('a'..'h').each { |letter| print "#{letter} "}
    puts
  end
end

# board = Board.new

# require_relative 'player'

# board = Board.new
# board.setup_pieces
# board.render
# puts ""
# player = Player.new("test", :white)
# player_two = Player.new("te", :black)

# white ver



# # black ver

# board.move_piece(player, [6, 0], [4, 0])
# board.render
# p board.grid[4][1].available_moves(board)
# puts

# # board.move_piece(player_two, [4, 1], [5, 0])
# # board.render

# board.move_piece(player, [6, 2], [4, 2])
# board.render
# p board.grid[4][1].available_moves(board)
# puts

# # board.move_piece(player_two, [4, 1], [5, 2])
# # board.render

# p player_two.captured_pieces

# board.render
# board.move_piece(player, [6, 0], [4, 0])
# board.move_piece(player_two, [3, 1], [4, 1])
# p board.grid[4][1].available_moves(board)
