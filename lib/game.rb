require_relative 'board'
require_relative 'player'

class Game
  attr_reader :board
  attr_accessor :current_player

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
      player_input = parse(input)
      verified_input = input.match?(/^[a-h][1-8]$/i) && spot_empty?(player_input)
      return player_input if verified_input && correct_player_piece?(player_input)
    end
  end

  def parse(player_input)
    row = (player_input[1].to_i - 8).abs
    col = player_input[0].downcase.ord - 97 # 0 based indexing

    [row, col]
  end

  def reparse(player_input)
    letter = (player_input[1] + 97).chr
    number = (player_input[0] - 8).abs

    coord = letter.to_s + number.to_s
  end

  def play_turn
    loop do
      @board.render
      piece = get_piece(player_input)
      available_moves = show_available_moves(piece)
      puts "Choose move"
      puts available_moves
      player_input = gets.chomp
      move_piece(@current_player, available_moves, piece, player_input)
      @board.render
      puts ""
      swap_turn
    end
  end

  def get_piece(player_input)
    row, col = player_input
    @board.grid[row][col]
  end

  def show_available_moves(piece)
    piece.available_moves(@board)
  end

  def move_piece(current_player, available_moves, piece, player_input)
    move_chosen = available_moves[player_input.to_i]
    @board.move_piece(current_player, piece.current_pos, move_chosen)
  end
end

game = Game.new
game.play_turn

