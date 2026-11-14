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

  def special_move(board, to)
    # special move like castling
    nil
  end

  def special_capture_move(board, to)
    # special capture like en passant
    nil 
  end

  def attacked_squares(board)
    valid_moves(board)
  end

  def universal_moves(board)
    # combined capture and non-capture moves
    valid_moves(board) + valid_capture_moves(board)
  end

  def within_boundary?(row, col, board)
    row.between?(0, board.grid.length - 1) && col.between?(0, board.grid.length - 1)
  end
  
  def empty?(row, col, board)
    return false unless within_boundary?(row, col, board)

    board.grid[row][col].nil?
  end

  def opponent_piece?(row, col, board)
    return false unless within_boundary?(row, col, board)

    target = board.grid[row][col]
    !target.nil? && target.color != @color
  end
end