class Array
  def unwrap
    inject([]) {|m,x| m + x}
  end

  def sum 
    inject(0) {|m,n| m + n}
  end

  def product
    inject(1) {|m,n| m * n}
  end
end


class Grid

  DIMENSION=10
  SHIP_COUNTS = {
    2 => 1,
    3 => 2,
    4 => 1,
    5 => 1
  }
  
  HIT_UPDATE_COEFFICIENTS = [0,36, 30, 18, 10]
  MISS_UPDATE_COEFFICIENTS = [0, 1/9.0, 1/7.5, 1/4.5, 1/2.5]

  class << self
    def gaussian(dimension=DIMENSION)
      new(dimension) {|x, y| dimension - (dimension/2-x).abs.floor - (dimension/2-y).abs.floor}.normalise
    end

    def uniform(dimension=DIMENSION)
      new(dimension) {|x,y| 1 }.normalise
    end

    def from_a(array)
      new(array.length) {|x, y| array[y][x] } 
    end

    def choose_positions
      ships = SHIP_COUNTS.map {|k,v| Array.new(v,k)}.flatten.shuffle
      ships.inject([Grid.gaussian, []]) do |(grid, positions), size|
        new_grid, position = *grid.choose_position(size)
        [new_grid, positions + [position]]
      end[1]
    end

    def from_game_state(state)
      state.each_with_index.inject(Grid.uniform) {|grid, (row, y)|
        row.each_with_index.inject(grid) {|grid2, (label, x)|
          case label
          when :hit
            HIT_UPDATE_COEFFICIENTS.each_with_index.inject(grid2) do |grid3, (c, i)|
              grid3.neighbours_at_radius(x,y, i).inject(grid3) {|g, (x2, y2)| grid3.update_value(x2,y2) {|v| v * c }}
            end
          when :miss
            MISS_UPDATE_COEFFICIENTS.each_with_index.inject(grid2) do |grid3, (c, i)|
              grid3.neighbours_at_radius(x,y, i).inject(grid3) {|g, (x2, y2)| grid3.update_value(x2,y2) {|v| v * c }}
            end
          else
            grid2
          end
        }
      }
    end

    def choose_shot(game_state)
      from_game_state(game_state).choose_point
    end
  end

  def initialize(dimension=DIMENSION, &block)
    @dimension = dimension
    @grid = (0..dimension-1).map {|y| (0..dimension-1).map {|x| block.call(x,y) }} 
  end

  def to_a
    @grid
  end

  def to_s
    @grid.map {|row| row.join("  |  ")}.join("\n")
  end

  def normalise
    map {|n| n/sum.to_f }
  end

  def sum
    inject(0) {|m,n| m + n }
  end
  
  def map(&block)
    Grid.from_a(@grid.each_with_index.map {|row, y| row.each_with_index.map {|elem,x| block.call(elem,x,y)}})
  end

  def inject(initial, &block)
    @grid.each_with_index.inject(initial) { |row_memo, (row, y)|
      row.each_with_index.inject(row_memo) {|memo, (elem, x)| block.call(memo, elem, x, y)}  
    }
  end

  def map_inject(initial, &block) 
    Grid.from_a(@grid.each_with_index.inject([initial, []]) { |(accum, rows), (row, y)|
      new_accum, row = *row.each_with_index.inject([accum, []]) {|(row_accum, row), (elem, x)| 
        new_elem = block.call(row_accum, elem,x,y)
        [new_elem, row + [new_elem]]
      }
      [new_accum, rows + [row]]
    }[1])
  end

  def cdf
    normalise.map_inject(0) {|m, n| m+n }
  end

  def update_value(x, y, &block)
    new_grid = @grid.dup
    if new_grid[y] && new_grid[y][x]
      new_grid[y][x] = block.call(@grid[y][x])
    end
    Grid.from_a(new_grid)
  end

  def value_at(x,y)
    @grid[y] ? @grid[y][x] : nil
  end

  def choose_point
    n = rand
    cdf.map {|m| m >= n }.map {|val, x, y| [val,x,y] }.to_a.unwrap.find {|val, x, y| val }[1..-1]
  end

  def neighbours_in_direction_at_radius(x,y, radius, direction)
    if direction == :across
      [[x+radius, y], [x-radius, y]]
    else
      [[x, y+radius], [x, y-radius]]
    end
  end


  def neighbours_at_radius(x, y, radius)
    neighbours_in_direction_at_radius(x,y,radius, :across) + neighbours_in_direction_at_radius(x,y, radius, :down) 
  end  

  def choose_position(size)
    orientation = rand(2) == 1 ? :across : :down
    grid = normalise.map do |elem, x, y|
      occupied = (0..size-1).map { |n| orientation == :across ? [x+n, y] : [x, y+n] }.map {|x,y| value_at(x,y) || 0}.uniq
      occupied.product 
    end.normalise
    x, y = *grid.choose_point
    new_grid = (0..size-1).map {|n| orientation == :across ? [x+n, y] : [x, y+n]}.uniq.inject(self) { |g, (x, y)|
      MISS_UPDATE_COEFFICIENTS.each_with_index.inject(g) {|g2, (c, i)|
        neighbours_at_radius(x,y, i).inject(g2) {|g3, (x2, y2)| g3.update_value(x2,y2) {|v| v * c }}
      }
    }
    return [new_grid, [x, y, size, orientation]]
  end

end
