class StateReader
  def read_board(state, ships_remaining)
    ships = []
    coordinates = get_hit_coordinates(state)
    coordinates.each do |coordinate|
      right = [coordinate[0] + 1, coordinate[1]]
      down = [coordinate[0], coordinate[1] + 1]
      left = [coordinate[0] - 1, coordinate[1]]
      up = [coordinate[0], coordinate[1] - 1]
      current_ship = Ship.new

      if coordinates.include?(right)
        current_ship.orientation = :horizontal
      elsif coordinates.include?(down)
        current_ship.orientation = :vertical
      end
      unless coordinates.include?(left) || coordinates.include?(up)
        ships << current_ship
      end
    end
    return ships
  end

  private
  def get_hit_coordinates(state)
    all_cells = state.flatten
    flat_hit_coordinates = all_cells.size.times.select {|i| all_cells[i] == :hit}

    ncols = state.first.size
    rows = flat_hit_coordinates.map{|pos| pos/ncols}
    columns = flat_hit_coordinates.map{|pos| pos % ncols}

    return rows.zip(columns)

  end
end
