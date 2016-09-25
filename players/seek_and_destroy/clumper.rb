class Clumper
  def clump(state)
    clumps = []
    coordinates = get_hit_coordinates(state)
    if coordinates.size > 0
    center = coordinates[0]
    clump = []
    find_clumps(coordinates, center, clump)
    clumps << clump
  end
    clumps
  end

  def find_clumps(coordinates, center, clump)
    coordinates -= [center]
    clump << center
    adjacents = [[center[0] + 1, center[1]], [center[0], center[1] + 1], [center[0] - 1, center[1]], [center[0], center[1] - 1]]
    adjacents.each do |adjacent|

    if coordinates.include?(adjacent)
      coordinates -= [adjacent]
      find_clumps(coordinates, adjacent, clump)
    end
  end
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
