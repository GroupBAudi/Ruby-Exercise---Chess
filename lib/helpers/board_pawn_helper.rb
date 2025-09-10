module BoardPawnHelper
  def trigger_en_passant(piece, board)
    piece.en_passant?(board)
    reset_en_passant_flag(board)
  end

  def en_passant_capture(from, to, piece, current_player)
    direction = piece.color == :white ? 1 : -1
    target_row, target_col = to
    target_piece = [target_row + direction, target_col]
    current_player.captured_pieces << piece_at(target_piece)
    set_piece_at(target_piece, nil)
    place_piece(from, to, piece)
  end

  def reset_en_passant_flag(board)
    last_piece_coord = board.last_move[-2]
    if !last_piece_coord.nil?
      piece = piece_at(last_piece_coord.last)
      piece.en_passant = false if piece
    end
  end
end