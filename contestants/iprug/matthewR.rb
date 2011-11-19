class MatthewRPlayer
  def initialize
    @state = Array.new(10) { Array.new(10,:unknown) }
    @last_coords = nil
    @hits_list = []
    @last_ships = []
    @unalloc_sunk_len = 0
    @last_deltas = nil
  end

  def name
    "Matthew Robinson"
  end

  def new_game
    # top secret info. Ideally replace with a random choice (and/or try and make use of the probabilities)

    #[ [0,4,5, :down], [2,9,4, :across], [9,7,3, :down], [5,6,3, :across], [5,7,2, :down]]
    @state = Array.new(10) { Array.new(10,:unknown) }
    ship_lengths = [5,4,3,3,2]
    ship_lengths.map do |len|
      x,y,orient = nil
      loop do
        x=rand(10)
        y=rand(10)
        orient = (rand(2) == 1) ? :down : :across
        break if ship_fits?(x,y,len,orient)
      end
      record_ship(x,y,len,orient)
      [x,y,len,orient]
    end
  end

  def state_at(coords)
    # return the state at this co-ordinate
    # if co-ordinates are outside the grid return a default value of :miss
    
    x=coords[0]
    y=coords[1]
    if (0..9) === x and (0..9) === y
      return @state[y][x]
    else
      return :miss
    end
  end

  def apply_ship(len)
    counts = Array.new(10) { Array.new(10,0) }
    [:down, :across].each do |orient|
      0.upto(9) do |x|
        0.upto(9) do |y|
          if ship_fits?(x,y,len,orient)
            0.upto(len-1) do |delta|
              if orient == :down
                counts[y+delta][x]+=1
              elsif orient == :across
                counts[y][x+delta]+=1
              end
            end
          end
        end
      end
    end
    return counts
  end

  def ship_fits?(x,y,len,orient)
    fits=true
    0.upto(len-1) do |delta|
      if orient == :down
        fits &= state_at([x,y+delta])==:unknown
      elsif orient == :across
        fits &= state_at([x+delta,y])==:unknown
      end
    end
    fits
  end

  def record_ship(x,y,len,orient)
    0.upto(len-1) do |delta|
      if orient == :down
        @state[y+delta][x]= :ship
      elsif orient == :across
        @state[y][x+delta]= :ship
      end
    end
  end

  def total_count(counts)
    counts.inject(0) do |acc,row| 
      acc + row.inject { |a,b| a+b }
    end
  end

  def normalise(counts,len)
    total = total_count(counts)
    factor = (total>0) ? (len * 1.0 / total) : 0

    counts.map do |row|
      row.map do |value|
        value * factor
      end
    end
  end

  def sum_counts(counts_arrays)
    results = Array.new(10) { Array.new(10,0) }

    counts_arrays.each do |counts|
    
      0.upto(9) do |x|
        0.upto(9) do |y|
          results[y][x] = (results[y][x]) + (counts[y][x])
        end
      end
    end
    return results
  end

  def try_coords(coords)
    #either return the co-ordinates if a valid move or else nil
    state_at(coords) == :unknown ? coords : nil
  end

  def sum_coords(a,b)
    # return sum of two co-ordinates
    x = a[0] + b[0]
    y = a[1] + b[1]
    [x,y]
  end

  def coords_of_max(grid)
    #return the [x,y] coords of the square with highest value
    
    m =-1
    x_of_max =-1
    y_of_max =-1

    0.upto(9) do |x|
      0.upto(9) do |y|
        if grid[y][x] > m
          m=grid[y][x]
          x_of_max = x
          y_of_max = y
        end
      end
    end

    [x_of_max, y_of_max]
  end


  def find_ships(ships_remaining)
    # return the square with the highest probability of hitting a ship
    
    probabilities_per_ship = ships_remaining.map do |ship_len|
      normalise(apply_ship(ship_len), ship_len)		
    end

    coords_of_max(sum_counts(probabilities_per_ship))
  end

  def take_turn(state, ships_remaining)
    @state = state

    shot=nil 

    unless @last_coords.nil?
      #see what happened with our previous shot
      if state_at(@last_coords) == :hit
        @hits_list << @last_coords
        if @last_ships.length > ships_remaining.length
          #we sunk a ship so work out which one
          sunk_len = (@last_ships - ships_remaining).last
          sunk_len ||= 3 # fix for length 3 ships (as we may have sunk first one and still have a len 3 ship in both lists)
          @unalloc_sunk_len += sunk_len
          if @hits_list.length == @unalloc_sunk_len
            #all hits are due to these ship(s), so no need to search further
            @hits_list = []
            @unalloc_sunk_len =0
          end
        else
          if @hits_list.length > 1
            #try carrying on in same direction
            shot = try_coords(sum_coords(@last_coords, @last_deltas))
          end
        end
      end

      #if we haven't yet found a square, try searching around existing hits
      if shot.nil?
        @hits_list.each do |hit|
          [[1,0], [-1,0], [0,1], [0,-1]].each do |deltas|
            @last_deltas = deltas if shot.nil?
            shot ||= try_coords(sum_coords(hit, deltas))
          end
        end
      end
    end
	
    shot ||= find_ships(ships_remaining) #if nothing better to do, then open up a new area of the board
		
    #store relevant state
    @last_coords= shot
    @last_ships=ships_remaining.dup
    shot # return the shot we want to take
  end

end #end of class
