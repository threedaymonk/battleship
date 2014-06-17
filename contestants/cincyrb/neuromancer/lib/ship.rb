class Ship
  def initialize(*args)
    @x, @y, @length, @orientation = args.flatten
  end

  attr_reader :x, :y, :length, :orientation

  # The (x, y) coordinates of this ship as a two-element array.
  def coordinates
    [@x, @y]
  end

  # All points covered by this ship as an array of coordinates.
  def points
    case orientation
    when :across
      (x...x+length).map {|x1| [x1, y]}
    when :down
      (y...y+length).map {|y1| [x, y1]}
    end
  end

  def to_a
    [@x, @y, @length, @orientation]
  end
end
