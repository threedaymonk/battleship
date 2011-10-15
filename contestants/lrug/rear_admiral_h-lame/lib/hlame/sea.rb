class Sea
  def initialize(size=10)
    @sea_of_battle = []
    10.times do |y|
      @sea_of_battle[y] = []
      10.times do |x|
        @sea_of_battle[y][x] = :unknown
      end
    end
  end

  def x_size
    @sea_of_battle[0].size
  end

  def y_size
    @sea_of_battle.size
  end

  def collision?(attempt)
    short_form_to_long_form_ship_placement(attempt).any? do |coord|
      x, y = *coord
      @sea_of_battle[y][x] != :unknown
    end
  end

  def deploy(ship_placement)
    short_form_to_long_form_ship_placement(ship_placement).each do |coord|
      x, y = *coord
      @sea_of_battle[y][x] = :ship
    end
  end

  def update(x, y, new_state)
    @sea_of_battle[y][x] = new_state
  end

  def hit_count
    self.hits.length
  end

  def hits
    co_ords_of_all :hit
  end

  def unknown_count
    self.unknowns.length
  end

  def unknowns
    co_ords_of_all :unknown
  end

  def random_position(for_state = :unknown)
    all_for_state = co_ords_of_all for_state
    all_for_state[rand(all_for_state.length)]
  end

  def positions_around(center, size)
    x_c, y_c = *center
    all = 1.upto(size).map { |mod| 
      [[x_c + mod, y_c], 
       [x_c - mod, y_c],
       [x_c, y_c + mod],
       [x_c, y_c - mod]]
    }.flatten(1).
      reject do |co_ord| 
        x, y = *co_ord
        (x >= x_size || x < 0) ||
        (y >= y_size || y < 0)
      end
    all.zip all.map {|co_ord| @sea_of_battle[co_ord.last][co_ord.first]}
  end
  
  def positions(*positions)
    positions.map { |pos|
      x, y = *pos
      [pos, @sea_of_battle[y][x]]
    }
  end

  def to_s
    @sea_of_battle.map do |cols|
      cols.map do |cell|
        case cell
        when :unknown
          '.'
        when :ship, :hit
          '#'
        when :miss
          '+'
        end
      end.join(' ')
    end.join("\n")
  end

  private
  def short_form_to_long_form_ship_placement(ship_placement)
    x,y,ship,orientation = *ship_placement

    ship_coords = ship.times.map do |i|
      if orientation == :across
        [x+i, y]
      else
        [x, y+i]
      end
    end
  end
  
  def co_ords_of_all(state)
    self.x_size.times.map do |x|
      self.y_size.times.select do |y|
        @sea_of_battle[y][x] == state
      end.map {|y| [x,y]}
    end.compact.flatten(1)
  end
end
