# Class that holds everything about pieces' hierarchy
# Movement logic that will be overridden by said piece
class Piece
  def initialize(color, symbol, position)
    @color = color
    @symbol = symbol
    @position = position
  end

  def valid_moves(board)
  end

  def bfs(start, target)
  end

  def moves(start, target)
  end

  def build_path(parent, target)
  end
end