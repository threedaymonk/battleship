class RandomPlacement
  def initialize(lengths, size)
    @lengths   = lengths
    @size      = size
    @board     = {}
    @positions = place
  end

  attr_reader :positions

private
  def place
    @lengths.map{ |length|
      find_valid_position(length).tap{ |position|
        place_ship *position
      }
    }
  end

  def can_place_ship?(x, y, length, direction)
    cells = expand_position(x, y, length, direction)
    cells.all?{ |(x,y)| x < @size && y < @size } && cells.none?{ |xy| @board[xy] }
  end

  def place_ship(x, y, length, direction)
    expand_position(x, y, length, direction).each do |xy|
      @board[xy] = true
    end
  end

  def expand_position(x, y, length, direction)
    dx, dy = direction == :across ? [1, 0] : [0, 1]
    (0 ... length).map{ |i| [x + i * dx, y + i * dy] }
  end

  def find_valid_position(length)
    loop do
      position = [
        rand(@size),
        rand(@size),
        length,
        [:across, :down].sample
      ]
      return position if can_place_ship?(*position)
    end
  end
end
