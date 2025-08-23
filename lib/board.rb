require_relative 'pieces'
# require_relative 'piece/pawn'

# Holds all logic related to positioning and collisions
class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    # setup_pieces
  end

  def setup_pieces
    # initialize pieces
    # white and black pawns as well as greater pieces 

    # setup pawns
    (0..7).each do |col|
      @grid[6][col] = Pawn.new(:white, [6, col])
      @grid[1][col] = Pawn.new(:black, [1, col])
    end
  end

  def render
    @grid.each do |row|
      puts row.map { |cell| cell.nil? ? "." : cell.symbol }.join(" ")
    end
  end
end

# test = Board.new
# test.render
