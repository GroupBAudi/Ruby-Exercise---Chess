class Player
  attr_reader :name, :color

  def initialize(name, color)
    @name = name
    @color = color
  end

  def to_s
    "#{name} (#{color})"
  end
end
