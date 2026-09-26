require_relative 'board'
require_relative 'player'
require_relative 'helpers/board_parser'

class Game
  attr_reader :board
  attr_accessor :current_player

  include BoardParser

  def initialize(board = Board.new)
    @board = board
    @player_one = Player.new("Player one", :white)
    @player_two = Player.new("Player two", :black)
    @current_player = @player_one
    @board.setup_pieces
  end

  def swap_turn
    @current_player = (@current_player == @player_one) ? @player_two : @player_one
  end

  def correct_player_piece?(player_input)
    row, col = player_input
    piece = @board.grid[row][col]
    if @current_player.color != piece.color
      puts "#{reparse(player_input)} is #{piece.color}'s piece"
      return false
    end
    true
  end

  def spot_empty?(player_input)
    row, col = player_input
    if @board.grid[row][col].nil?
      puts "#{reparse(player_input)} is empty"
      return false
    end
    true
  end

  def player_input
    loop do
      input = gets.chomp.strip.slice(0, 2)
      if input.match?(/^[a-h][1-8]$/i)
        player_input = parse(input)
        verified_input = input.match?(/^[a-h][1-8]$/i) && spot_empty?(player_input)
      end
      return player_input if verified_input && correct_player_piece?(player_input)
      puts "Invalid coordinate. Enter a square like a2 or e4."
    end
  end

  def move_input
    loop do
      player_input = gets.chomp.strip

      return player_input if player_input.match?(/^[a-h][1-8]$/i) || player_input.match?(/^\d+$/) || player_input.match?(/^(cancel|c|back|b)$/i)

      puts "Invalid coordinate. Enter a square like a2 or e4."
    end
  end

  def verify_input(available_moves)
    # check player input if it goes out of bound
    # if it does prompt back for move
    # else continue
    loop do
      input = move_input

      if input.match?(/^\d+$/)
        return input if available_moves.key?(input.to_i)
      else
        return input if available_moves.value?(parse(input))
      end

      return :cancel if input.match?(/^(cancel|c|back|b)$/i)

      puts "out of range"
    end
  end

  def play_turn
    # render board
    # ask for move
    # pick/execute what kind of move
    # swap turn
    # check endgame_status for the new current player
    # render board again
    loop do
      @board.render
      puts "Get move (choose a2, b1 etc)"
      piece = get_piece(player_input)
      available_moves = show_available_moves(piece)

      if available_moves.empty?
        puts "That has no legal moves"
        next
      end

      puts "Choose move (input array index, 0 - n OR type coordinate; or '_c_ancel' or '_b_ack' to cancel)"
      display_moves = available_moves.map{ |x, y| "#{x}: " + reparse(y) }
      p display_moves

      player_input = verify_input(available_moves)

      next if player_input == :cancel

      move_piece(available_moves, piece, player_input)
      swap_turn
      status = @board.endgame_status(@current_player.color)
      # status if board.in_check?(@current_player.color)
      @board.render
      puts ""
    end
  end

  # def check_game_status
  #   status = @board.endgame_status(@current_player.color)

  #   case status
  #   when :checkmate
  #     # announce + indicate game should end
  #   when :stalemate
  #     # announce + indicate game should end
  #   else
  #     # maybe check ordinary in_check? here
  #     puts "checkmate"
  #   end
  # end

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
    elsif player_input.match?(/^\d+$/)
      # index style: "0", "1", "2"...
      player_input = player_input.to_i
      move_chosen = available_moves[player_input]
    end
    # 2. Tell the board to execute the move and CATCH the returned item (if any)
    captured_piece = @board.move_piece(piece.current_pos, move_chosen)
    # 3. if an item is returned, increment to current player captured pieces
    @current_player.captured_pieces << captured_piece if captured_piece
  end
end

game = Game.new
game.play_turn
