require 'ship'

class BattleshipBoard
  def initialize(row_count=10, col_count=row_count)
    @row_count = row_count
    @col_count = col_count
    @x_range = 0...row_count
    @y_range = 0...col_count

    @state = [([:unknown] * @col_count)] * @row_count
  end

  attr_reader :row_count, :col_count, :x_range, :y_range, :ships_remaining

  def update!(state, ships_remaining)
    @state = state

    @ships_remaining ||= ships_remaining.sort.reverse
    @ship_sunk = find_sunk_ship(@ships_remaining, ships_remaining)
    @ships_remaining = ships_remaining.sort.reverse
  end

  # Returns the state of the cell (x, y) as one of :hit, :miss, or :unknown.
  def [](x, y)
    row = @state[y]
    row ? row[x] : nil
  end

  # Returns the length of the ship sunk on the last round, or nil.
  def ship_sunk?
    @ship_sunk
  end

  # Is the given point or ship fully within the confines of the board?
  def on_board?(*args)
    x, y, length, direction = args.flatten

    x_max = x
    y_max = y
    case direction
    when :across
      x_max = x + length
    when :down
      y_max = y + length
    end

    @x_range.cover?(x) && @y_range.cover?(y) && @x_range.cover?(x_max) && @y_range.cover?(y_max)
  end

  NEIGHBOR_OFFSETS = [[0,-1], [1,0], [0,1], [-1,0]].freeze

  def neighbors(*args, &filter)
    x, y = args.flatten
    filter ||= ->(_) { true }

    NEIGHBOR_OFFSETS.reduce([]) { |memo, offset|
      x1, y1 = point = [x + offset[0], y + offset[1]]
      memo << point if on_board?(x1, y1) && filter.call(self[x1, y1])
      memo
    }
  end

  def each_coordinate
    for x in x_range
      for y in y_range
        yield x, y
      end
    end
  end

  private

  def find_sunk_ship(ships1, ships2)
    return nil if ships1.size == ships2.size

    ships1 = ships1.sort.reverse
    ships2 = ships2.sort.reverse

    for i in (0..[ships1.size, ships2.size].max)
      l1 = ships1[i] || 10000
      l2 = ships2[i] || 10000
      return [l1, l2].min unless l1 == l2
    end

    nil
  end
end
