require_relative 'board'
require_relative 'player'
require_relative 'helpers/board_parser'
require_relative 'helpers/save_game'
require_relative 'helpers/renderer'

class Game
  attr_reader :board, :player_one, :player_two
  attr_accessor :current_player

  include BoardParser, SaveGame, Renderer

  def initialize(board = Board.new)
    @board = board
    @player_one = Player.new("Player one", :white)
    @player_two = Player.new("Player two", :black)
    @current_player = @player_one
    @board.setup_pieces
    @message = nil
  end

  def swap_turn
    @current_player = (@current_player == @player_one) ? @player_two : @player_one
  end

  def correct_player_piece?(player_input)
    row, col = player_input
    piece = @board.grid[row][col]
    if @current_player.color != piece.color
      @message = "#{reparse(player_input)} is #{piece.color}'s piece"
      return false
    end
    true
  end

  def spot_empty?(player_input)
    row, col = player_input
    if @board.grid[row][col].nil?
      @message = "#{reparse(player_input)} is empty"
      return false
    end
    true
  end

  def player_input
    loop do
      render_screen("Get move (choose a2, b1 etc)")

      input = gets.chomp.strip

      unless input.match?(/\A[a-h][1-8]\z/i)
        @message = "Invalid coordinate. Enter a square like a2 or e4."
        next
      end

      coordinate = parse(input)

      if spot_empty?(coordinate) && correct_player_piece?(coordinate)
        @message = nil
        return coordinate
      end
    end
  end

  def move_input
    loop do
      player_input = gets.chomp.strip

      if player_input.match?(/\A[a-h][1-8]\z/i) ||
        player_input.match?(/\A\d+\z/) ||
        player_input.match?(/^(cancel|c|back|b|e|exit)$/i)

        @message = nil
        return player_input
      end

      @message = "Invalid coordinate. Enter a square like a2 or e4."
      render_screen(
        "Choose a move"
      )
    end
  end
  
  def verify_input(available_moves)
    # check player input if it goes out of bound
    # if it does prompt back for move
    # else continue
    loop do
      input = move_input

      display_moves = available_moves.map{ |x, y| "#{x}: " + reparse(y) }
      
      return :cancel if input.match?(/^(cancel|c|back|b|e|exit)$/i)

      if input.match?(/\A\d+\z/) # regex checks for index style input
        return input if available_moves.key?(input.to_i)
      else
        return input if available_moves.value?(parse(input))
      end

      render_screen(
        "That move is out of range. Please choose a valid move.",
        display_moves.join("\n")
        )
    end
  end

  def play_turn
    # ask for move
    # pick/execute what kind of move
    # swap turn
    # check endgame_status for the new current player
    loop do
      break if game_over?
      
      piece = get_piece(player_input)
      available_moves = show_available_moves(piece)

      if available_moves.empty?
        render_screen("That has no legal moves")
        next
      end

      render_screen(
        "Choose move (input array index, 0 - n OR type coordinate; or '_c_ancel' or '_b_ack' to cancel)",
        "Piece selected #{reparse(piece.current_pos)}",
        available_moves.map{ |x, y| "#{x}: " + reparse(y) }.join("\n")
      )
      
      player_input = verify_input(available_moves)

      next if player_input == :cancel

      move_piece(available_moves, piece, player_input)
      promotion_available?(piece)
      swap_turn
      puts ""
    end
  end

  def game_over?
    status = @board.endgame_status(@current_player.color)

    case status
    when :checkmate
      puts "checkmate"
      return true
    when :stalemate
      puts "stalemate"
      return true
    else
      # maybe check ordinary in_check? here
      puts "check" if @board.in_check?(@current_player.color)
    end
  end

  def promotion_available?(piece)
    # get piece's current position, check if it is a pawn and if it is on the back rank
    x, y = piece.current_pos
    backrank = piece.color == :white ? [0, y] : [7, y]

    if piece.is_a?(Pawn) && piece.current_pos == backrank
      p "Promotion!"
      # prompt class, color, pass pawn's current pos
      @board.promote_piece(piece, promotion_prompt)
    end
  end

  def promotion_prompt
    # give choice, 0 is queen 1 is rook 2 is knight 3 is bishop
    hash = {}
    classes = [Queen, Rook, Knight, Bishop].each_with_index { |c, i| hash[i] = c }
    puts hash

    loop do
      input = gets.chomp.strip.slice(0, 1)
    
      if input.match?(/^[0-3]$/i)
        case input.to_i
        when 0
          return Queen
        when 1
          return Rook
        when 2
          return Knight
        when 3
          return Bishop
        end
      end
      puts "Invalid input. Enter a number between 0 and 3."
    end
  end

  def get_piece(player_input)
    @board.piece_at(player_input)
  end

  def show_available_moves(piece)
    array = @board.legal_moves(piece)
    moves = {}
    array.each_with_index { |cell, i| moves[i] = cell }
    moves
  end

  def move_piece(available_moves, piece, player_input)
    # Reject if move is out of space
    if player_input.match?(/^[a-h][1-8]$/i)
      # coordinate style: "a4"
      player_input = parse(player_input)
      move_chosen = available_moves.values.find { |x| x == player_input}
    elsif player_input.match?(/\A\d+\z/)
      # index style: "0", "1", "2"...
      player_input = player_input.to_i
      move_chosen = available_moves[player_input]
    end
    # 2. Tell the board to execute the move and CATCH the returned item (if any)
    captured_piece = @board.move_piece(piece.current_pos, move_chosen)
    # 3. if an item is returned, increment to current player captured pieces
    @current_player.captured_pieces << captured_piece if captured_piece && captured_piece.color != @current_player.color
  end
end
