class BattleshipBoard
  def initialize(row_count=10, col_count=row_count)
    @row_count = row_count
    @col_count = col_count
    @x_range = 0...row_count
    @y_range = 0...col_count
  end

  attr_reader :row_count, :col_count, :x_range, :y_range

  def update!(state, ships_remaining)
    @state = state
    @ships_remaining = ships_remaining
  end

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

