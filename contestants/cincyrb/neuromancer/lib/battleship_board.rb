class BattleshipBoard
  def initialize(row_count=10, col_count=row_count)
    @row_count = row_count
    @col_count = col_count
    @x_range = 0...row_count
    @y_range = 0...col_count
  end

  attr_reader :row_count, :col_count, :x_range, :y_range, :ships_remaining

  def update!(state, ships_remaining)
    @state = state

    @ships_remaining ||= ships_remaining
    @ship_sunk = @ships_remaining.count > ships_remaining.count
    @ships_remaining = ships_remaining
  end

  # Returns the state of the cell (x, y) as one of :hit, :miss, or :unknown.
  def state(x, y)
    @state[y][x]
  end

  # Was a ship sunk on the last round?
  def ship_sunk?
    @ship_sunk
  end

  # Is the given ship fully within the confines of the board?
  def on_board?(ship)
    x, y, length, direction = ship

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
end

