# Renders board and pieces to the console
module Renderer
  def render(player_one, player_two)
    puts "#{player_two.name}: #{player_two.show_captured_pieces}"
      (1..8).to_a.reverse.each_with_index do |letter, i|
        break if i >= @grid.size
        print "#{letter} "
        row = @grid[i]
        puts row.map { |cell| cell.nil? ? "." : cell.symbol }.join(" ")
      end

      print "  "
      ('a'..'h').each { |letter| print "#{letter} "}
      puts
    puts "#{player_one.name}: #{player_one.show_captured_pieces}"
  end

  def clear_screen
    print "\e[H\e[2J"
  end

  def render_screen(prompt, *additional_messages)
    @board.clear_screen
     # since @board is instance of Board,
     # we need to pass in instance variable from game.rb
    @board.render(@player_one, @player_two)

    puts @message if @message
    puts additional_messages unless additional_messages.empty?
    puts prompt
  end
end