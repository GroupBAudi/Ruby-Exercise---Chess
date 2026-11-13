class Player
  attr_reader :name, :color
  attr_accessor :captured_pieces

  def initialize(name, color)
    @name = name
    @color = color
    @captured_pieces = []
  end

  def to_s
    "#{name} (#{color})"
  end

  def show_captured_pieces
    @captured_pieces.map(&:symbol).join(' ')
  end
end
