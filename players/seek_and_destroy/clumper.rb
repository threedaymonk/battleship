class Clumper
  def clump(state)
    clumps = []
    coordinates = get_hit_coordinates(state)
    coordinates.each do |coordinate|
      clumps << coordinates
    end
    clumps
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
