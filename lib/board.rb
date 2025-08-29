require_relative 'pieces'
require_relative 'piece/pawn'

# Holds all logic related to positioning and collisions
class Board
  attr_reader :grid
  attr_accessor :removed_piece

  def initialize
    @grid = Array.new(8) { Array.new(8) }
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
    from_row, from_col = from
    target_row, target_col = to
    piece = @grid[from_row][from_col]
    target = @grid[target_row][target_col]
    if piece # if piece exists
      capture(current_player, to)
      place_piece(from, to, piece)
    else
      puts "Move rejected"
    end
  end

  def place_piece(from, to, piece)
    from_row, from_col = from
    target_row, target_col = to

    @grid[target_row][target_col] = piece
    @grid[from_row][from_col] = nil
    piece.current_pos = [target_row, target_col]
  end

  def capture(current_player, position)
    row, col = position
    target = @grid[row][col]

    return unless target
    @grid[row][col] = nil
    current_player.captured_pieces << target
  end

  def render
    @grid.each do |row|
      puts row.map { |cell| cell.nil? ? "." : cell.symbol }.join(" ")
    end
  end
end
