class Ships

  def initialize
    @initial_ships = [ 5, 4, 3, 3, 2]
  end

  def sunk_cells
    (@initial_ships - @ships).inject(:+)
  end

  def update_with ships
    @ships = ships
  end
end
