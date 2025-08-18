class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    setup_pieces
  end

  def setup_pieces
    # initialize pieces
    # white and black pawns as well as greater pieces
  end
end