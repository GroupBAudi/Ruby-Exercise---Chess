require_relative 'pieces'
require_relative 'piece/pawn'

# Holds all logic related to positioning and collisions
class Board
  attr_reader :grid
  attr_accessor :removed_piece

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    @removed_piece = [] # temporary to hold captured piece until player.rb is created
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
    # piece = grab whatever is at `from`
    # if piece exists AND to is in piece's legal moves
    #     if target square occupied by enemy → capture it
    #     move piece in @grid
    #     update piece.current_pos
    # else
    #     reject move
    from_row, from_col = from
    target_row, target_col = to
    piece = @grid[from_row][from_col]
    target = @grid[target_row][target_col]
    if piece # if piece exists
      capture(to)
      @grid[target_row][target_col] = piece
      @grid[from_row][from_col] = nil
      piece.current_pos = [target_row, target_col]
    else
      puts "Move rejected"
    end
  end

  def capture(position)
    row, col = position
    target = @grid[row][col]

    return unless target
    @grid[row][col] = nil
    @removed_piece << target
  end

  def render
    @grid.each do |row|
      puts row.map { |cell| cell.nil? ? "." : cell.symbol }.join(" ")
    end
  end
end
