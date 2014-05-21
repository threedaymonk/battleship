class JustinSmith
  def name
    "Justin Smith"
  end

  def new_game
    board = board.new

    [5, 4, 3, 3, 2].each do |length|
      Ship.randomly_place(length, board)
    end

    board.ships
  end

  def take_turn(state, ships_remaining)
    [rand(10), rand(10)]
  end

end


class Ship
  attr_reader :row, :col, :length, :orientation

  def initialize x, y, length, orientation
    @x = x
    @y = y
    @length = length
    @orientation = orientation
  end

  def each_position
    return to_enum(:each_position) unless block_given?
    length.times do |index|
      case @orientation
      when :across
        yield(@x + index, @y)
      else
        yield(@x, @y + index)
      end
    end
  end

  def collision? board
    each_position.any? do |x,y|
        board.occupied? x, y
    end
  end

  def to_a
    [@x, @y, @length, @orientation]
  end

  def Ship.randomly_place length, board
    while true
      orientation = [:across, :down].sample
      case @orientation
        when :across
          x_range = (0...(Board.size-length))
          y_range = (0...(Board.size))
        else
          x_range = (0...(Board.size-length))
          y_range = (0...(Board.size))
      end
      candidate = Ship.new(rand(x_range), rand(y_range), length, orientation)
      unless candidate.collision? board
        board.add_ship candidate
        return candidate
      end
    end
  end
end

class Board
  @@size = 10

  def Board.size
    @@size
  end

  def initialize
    @occupied = {}
  end

  def add_ship ship
    ship.each_position do |x,y|
      @occupied[[x,y]] = ship
    end
    ship
  end

  def occupied? x, y
    return true unless (0...@@size) === x && (0...@@size) === y
    @occupied[[x,y]]
  end

  def ships
    @occupied.values.uniq
  end
end