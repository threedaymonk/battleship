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
    right = [center[0] + 1, center[1]]
    down = [center[0], center[1] + 1]
    left = [center[0] - 1, center[1]]
    up = [center[0], center[1] - 1]

    if coordinates.include?(right)
      coordinates -= [right]
      find_clumps(coordinates, right, clump)
    end
    if coordinates.include?(down)
      coordinates -= [down]
      find_clumps(coordinates, down, clump)
    end
    if coordinates.include?(left)
      coordinates -= [right]
      find_clumps(coordinates, left, clump)
    end
    if coordinates.include?(up)
      coordinates -= [up]
      find_clumps(coordinates, up, clump)
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
