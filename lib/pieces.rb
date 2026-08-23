# Class that holds everything about pieces' hierarchy
# Movement logic that will be overridden by said piece
class Piece
  def initialize(color, position)
    @color = color
    @position = position
  end
  
  def valid_moves(board)
  end

  def moves
  end

  def after_move(board)
  end

  def expire_move_state
  end
end