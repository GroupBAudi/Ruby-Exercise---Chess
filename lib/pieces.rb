# Class that holds everything about pieces' hierarchy
# Movement logic that will be overridden by said piece
class Piece
  def initialize(color, position)
    @color = color
    @position = position
  end
  
  def valid_moves(board)
  end

  def moves(board)
    slide(board)
  end

  def after_move(board)
  end

  def expire_move_state
  end

  def special_capture_position(board, to)
    nil
  end

  def attacked_squares(board)
    valid_moves(board)
  end
end