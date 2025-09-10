module BoardParser
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
end