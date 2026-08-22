# Renders board and pieces to the console
module Renderer
  def render
      (1..8).to_a.reverse.each_with_index do |letter, i|
        break if i >= @grid.size
        print "#{letter} "
        row = @grid[i]
        puts row.map { |cell| cell.nil? ? "." : cell.symbol }.join(" ")
      end

      print "  "
      ('a'..'h').each { |letter| print "#{letter} "}
      puts
  end
end