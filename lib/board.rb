require_relative 'pieces'
require_relative 'pieces/pawn'
require_relative 'pieces/rook'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'helpers/renderer'

# Holds all logic related to positioning and collisions
class Board
  attr_reader :grid
  attr_accessor :removed_piece, :move_history

  include Renderer

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    @move_history = []
  end

  def setup_pieces
    # initialize pieces
    # white and black pawns as well as super pieces 

    # setup pawns
    (0..7).each do |col|
      @grid[6][col] = Pawn.new(:white, [6, col])
      @grid[1][col] = Pawn.new(:black, [1, col])
    end
  
    # setup any other pieces
    (0..1).each_with_index do |x, i|
      i = 1
      i = -1 if x == 1
      @grid[7][(0 + x) * i] = Rook.new(:white, [7, (0 + x) * i])
      @grid[7][(1 + x) * i] = Knight.new(:white, [7, (1 + x) * i])
      @grid[7][(2 + x) * i] = Bishop.new(:white, [7, (2 + x) * i])
      @grid[0][(0 + x) * i] = Rook.new(:black, [0, (0 + x) * i])
      @grid[0][(1 + x) * i] = Knight.new(:black, [0, (1 + x) * i])
      @grid[0][(2 + x) * i] = Bishop.new(:black, [0, (2 + x) * i])
    end

    # setup king and queen because irl courtship doesn't work like that
    [0, 7].each do |i|
      x = :black
      x = :white if i == 7
      @grid[i][3] = Queen.new(x, [i, 3])
      @grid[i][4] = King.new(x, [i, 4])
    end
  end

  def move_piece(from, to)
    piece = piece_at(from)
    return nil unless piece

    move_to(from, to, piece)
  end

  def capturing_condition(to)
    target = piece_at(to)
    !target.nil?
  end

  def move_to(from, to, piece)
    special_capture = piece.special_capture_position(self, to)
    if capturing_condition(to)
      # if piece exists and target is occupied
      capture(from, to, piece)
    elsif special_capture
      # if piece is a pawn and has en passant move available
      capture(from, to, piece, special_capture)
    else
      # just place piece if anything
      place_piece(from, to, piece)
      nil # returns nil because nothing is captured
    end
  end

  def piece_at(position) # getter
    # What occupies this square?
    x, y = position
    @grid[x][y]
  end

  def set_piece_at(position, value) # setter
    # Put this value on this square
    x, y = position
    @grid[x][y] = value
  end

  def remove_piece(position)
    # Remove and return what's on this square
    piece = piece_at(position)
    set_piece_at(position, nil)
    piece
  end

  def add_history(piece, current_position, target)
    @move_history << {
      piece: piece,
      from: current_position,
      to: target
    }
  end

  def expire_move_state
    return if @move_history.length < 2

    previous_piece = @move_history[-2][:piece]
    previous_piece.expire_move_state
  end

  def place_piece(from, to, piece)
    target_row, target_col = to
    piece.last_pos << piece.current_pos
    add_history(piece, piece.current_pos, to)
    set_piece_at(to, piece)
    set_piece_at(from, nil)
    piece.current_pos = [target_row, target_col]
    # flag a pawn with en passant if moving pawn class
    piece.after_move(self)
    # expire en passant if opportunity wasted
    expire_move_state
  end

  def capture(from, to, piece, capture_position = to)
    # move piece from from to to, while removing the piece at capture_position
    # where unless en passant, remove the occuppying grid on opponent piece pos
    target = remove_piece(capture_position)
    place_piece(from, to, piece)
    target
  end

  def in_check?(color)
    # check if all opposite color valid capture move has color king in it
    # check if valid capture move include other piece's king
    # include?(parse the array and check for grid location of king)
    @grid.each do |row|
      row.each do |col|
        next if col.nil? || col.color == color
        moves = col.valid_capture_moves(self)

        moves.each do |ele|
          return true if piece_at(ele).is_a?(King) && piece_at(ele).color == color
        end
      end
    end
    false
  end

  def find_king(color)
    @grid.each do |row|
      row.each do |col|
        next if col.nil? || col.color != color
        
        return col.current_pos if col.is_a?(King)
      end
    end
    nil
  end

  def king_under_attack?(color)
    # check if color's king possible movement were under attack by opposing piece
    # take every piece's current move, check if color's king possible move
    curr_king_moves = piece_at(find_king(color)).valid_moves(self)

    @grid.each do |row|
      row.each do |col|
        next if col.nil? || col.color == color
        moves = col.attacked_squares(self)
        # check if enemy available move overlaps with king's possible move
        
        return true if curr_king_moves.any? { |ele| moves.include?(ele) } 
      end
    end
    false
  end

  def current_piece_attackers(piece)
    # check what kind of pieces are attacking the parameter piece
    # iterate through the board to find enemy color
    # check all of their moves, see if it includes current piece's position
    curr_piece_pos = piece.current_pos
    attackers = []

    @grid.each do |row|
      row.each do |col|
        next if col.nil? || col.color == piece.color
        moves = col.moves(self)

        attackers << col if moves.any? { |ele| ele.include?(curr_piece_pos) }
      end
    end

    attackers
  end

  def reveal_king?(piece, color)
    # take current piece, check if possible move reveal 
    # if #slide attacks both king and current piece
    # remove valid move where row / column would expose king
    # The tested piece must be the only blocker between the enemy slider and the King.
    
    curr_king = piece_at(find_king(color))
    victims = [piece, curr_king]

    current_piece_attackers(piece).each do |enemy|
      moves = enemy.moves(self)

      # collect pieces by iterating
      # slide
      # if encounter piece, put in array
      # array can hold max of two elements
      # if pieces collected == victim and king, true

      moves.each do |ray|
        pieces = []
        ray.each do |coor|
          curr_piece = piece_at(coor)
          next if curr_piece.nil?

          pieces << curr_piece

          if pieces.length == 2
            return true if pieces == victims    
            break
          end
        end
      end 
    end
    false
  end

  def legal_moves(piece)
    # for each of the current piece movement
    # see if any of its movement could cause the king still be in check
    # push to array all the valid movements under the condition check is false
    color = piece.color
    curr_piece_moves = piece.valid_moves(self)
    valid_moves = []

    curr_piece_moves.each do |coor|
      curr_x, curr_y = piece.current_pos
      x, y = coor
      # save state of the board first
      backup = piece_at(coor)
      original_pos = piece.current_pos
      self.grid[curr_x][curr_y] = nil
      self.grid[x][y] = piece
      piece.current_pos = coor

      if in_check?(color) == false
        valid_moves << coor
      end
      # return state of board
      self.grid[x][y] = backup
      self.grid[curr_x][curr_y] = piece
      piece.current_pos = original_pos
    end
  valid_moves
  end

  def checkmate?(color)
    #     in_check?(color)    legal moves exist?
    # ────────────────────────────────────────
    # true                true      → check, but not mate
    # true                false     → CHECKMATE

    # if king is incheck
    # check every color's pieces legal moves
    # if all return [] including king, checkmate
    moves = []
    if in_check?(color)
      @grid.each do |row|
        row.each do |coor|
          next if coor.nil? || coor.color != color
          # current_piece = piece_at(coor)
          moves << legal_moves(coor)
        end
      end  
    end

    return true if moves.all? { |ele| ele == [] } && moves != []
    false
  end

  def stalemate?(color)
    #     in_check?(color)    legal moves exist?
    # ────────────────────────────────────────
    # false               true      → ordinary position
    # false               false     → STALEMATE
    
    # if king is not incheck
    # check if king is in danger of reveal
    moves = []
    unless in_check?(color)
      @grid.each do |row|
        row.each do |coor|
          next if coor.nil? || coor.color != color
          # current_piece = piece_at(coor)
          moves << legal_moves(coor)
        end
      end  
    end

    return true if moves.all? { |ele| ele == [] } && moves != []
    false
  end
end

# board = Board.new
# board.grid[4][4] = King.new(:white, [4, 4])
# x = board.grid[4][4]
# p x.empty?(-1, -1, board)

################# CHECKMATE TEST ###################

# board = Board.new

# # Black King being checkmated
# board.grid[0][0] = King.new(:black, [0, 0])

# # Helpless Black pieces elsewhere
# board.grid[0][7] = Rook.new(:black, [0, 7])
# board.grid[3][6] = Bishop.new(:black, [3, 6])
# board.grid[6][7] = Knight.new(:black, [6, 7])

# # White mating pieces
# board.grid[1][1] = Queen.new(:white, [1, 1])
# board.grid[2][2] = King.new(:white, [2, 2])

# board.render

# puts "CHECKMATE TEST 1 — WITH HELPLESS FRIENDS"
# puts "Black is in check: #{board.in_check?(:black)}"
# puts "Black is checkmated: #{board.checkmate?(:black)}"

# board = Board.new

# board.grid[0][0] = King.new(:black, [0, 0])
# board.grid[0][1] = Rook.new(:black, [0, 1])
# board.grid[1][0] = Pawn.new(:black, [1, 0])
# board.grid[1][1] = Pawn.new(:black, [1, 1])

# board.grid[0][7] = Rook.new(:white, [0, 7])
# board.grid[2][7] = King.new(:white, [2, 7])

# board.render

# puts "CHECKMATE TEST 2"
# puts "Black is in check: #{board.in_check?(:black)}"
# puts "Black is checkmated: #{board.checkmate?(:black)}"

############### STALEMATE TEST ########################

# board = Board.new

# board.grid[0][0] = King.new(:black, [0, 0])
# board.grid[1][2] = Queen.new(:white, [1, 2])
# board.grid[2][1] = King.new(:white, [2, 1])

# board.render

# puts "STALEMATE TEST 1"
# puts "Black is in check: #{board.in_check?(:black)}"
# puts "Black is stalemated: #{board.stalemate?(:black)}"

# puts "in_check?(:black)   => false"
# puts "stalemate?(:black)  => true"

# board = Board.new

# # Black
# board.grid[0][0] = King.new(:black, [0, 0])
# board.grid[0][7] = Rook.new(:black, [0, 7])

# board = Board.new

# board.grid[0][0] = King.new(:black, [0, 0])   # a8
# board.grid[1][2] = Queen.new(:white, [1, 2])  # c7
# board.grid[2][1] = King.new(:white, [2, 1])   # b6

# board.render
# puts "STALEMATE TEST 1"
# puts "Black in check:   #{board.in_check?(:black)}"     # expect false
# puts "Black stalemated: #{board.stalemate?(:black)}"    # expect true
# puts "King legal moves: #{board.legal_moves(board.grid[0][0]).inspect}"  # expect []
  