# Sliding as in moves directionally vertical/horizontal/diagonal

module SlidingMovement
  def valid_moves(board)
    x, y = @current_pos
    moves = []

    self.class::DIRECTIONS.each do |dx, dy|
      i = 1
      while within_boundary?(x + i * dx, y + i * dy, board) && empty?(x + i * dx, y + i * dy, board)
        
        new_x = x + i * dx
        new_y = y + i * dy      

        moves << [new_x, new_y]
        i += 1
      end
    end
    moves
  end

  def valid_capture_moves(board)
    x, y = @current_pos
    moves = []

    self.class::DIRECTIONS.each do |dx, dy|
      i = 1
      while within_boundary?(x + i * dx, y + i * dy, board) 
        new_x = x + i * dx
        new_y = y + i * dy      
        if !empty?(x + i * dx, y + i * dy, board) && opponent_piece?(x + i * dx, y + i * dy, board)
          moves << [new_x, new_y]
          break
        end
        break if !empty?(x + i * dx, y + i * dy, board) && !opponent_piece?(x + i * dx, y + i * dy, board)
        i += 1
      end
    end
    moves
  end
end