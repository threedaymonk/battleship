class JustinSmithPlayer

  def initialize
    @probabilities = [ 5/5.0, 4/5.0, 4/5.0, 3/5.0, 3/5.0]
    @prev_move = nil
    @prev_state = nil
    @prev_ships_remaining = nil
    @overlay = {}
  end

  def name
    'Justin Smith'
  end

  def new_game
    board = Board.new

    [5, 4, 3, 3, 2].each do |length|
      Ship.randomly_place(length, board)
    end

    board.ships.map {|ship| ship.to_a}
  end

  def take_turn(state, ships_remaining)
    ary = []
    ships_remaining.sort!

    apply_overlay(state)
    
    # If we made a kill, we need to update the overlay
    if @prev_ships_remaining.nil?
      @prev_ships_remaining = ships_remaining
    elsif ships_remaining != @prev_ships_remaining
      region = Region.new( @prev_move, state, :hit)
      fill_region region, :kill
      @prev_ships_remaining = ships_remaining
    end

    @prev_state = state

    #puts "Overlay: #{@overlay.size}"


    (0...Board.size).each do |x|
      (0...Board.size).each do |y|
        ary << Pos.new(x, y, state)
      end
    end

    ary.delete_if {|x| x.value == 0 }
    ary.shuffle!
    ary.sort!
    ary.reverse!

    puts ary[0..10].map {|x| x.value}.inspect

    # Probabilistically select move over geometric distribution
    prob = @probabilities[ships_remaining.length-1]
    i = 0
    while true
      if( rand() < prob )
        pos =  ary[i % ary.length]
        @prev_move = pos
        #puts "State: #{state[pos.x][pos.y]}"
        #puts "Pos: #{pos.inspect}"
        return [pos.y, pos.x]
      end
      i += 1
    end

  end

  private
  def fill_region region, value
    ((region.top+1)..(region.bottom-1)).each do |x|
      ((region.left+1)..(region.right-1)).each do |y|
        @overlay[[x,y]] = value
      end
    end
  end

  def apply_overlay state
    @overlay.each do |pos, value|
      state[pos[0]][pos[1]] = value
    end
  end

end


class Pos
  attr_reader :value, :x, :y

  def initialize(x, y, state, region_weight = 0.6, hit_value = 12)
    @x = x
    @y = y
    @value = 0
    # It only has value if it's unknown
    if state[x][y] == :unknown
      add_region_value(state, region_weight)
      add_hit_value(state, hit_value)
    end
  end

  def add_region_value(state, region_weight)

    # Check column
    region = Region.new self, state, :unknown
    # Add the smaller of the two
    @value += region.value

	end
		
  def add_hit_value(state, hit_value)
    # Check neighbors for hit
    if @x > 0 && state[@x-1][@y] == :hit
      @value += hit_value
      if @x > 1 && state[@x-2][@y] == :hit
        @value += 2*hit_value
      end
    end

    if @x < Board.size-1 && state[@x+1][@y] == :hit
      @value += hit_value
      if @x < Board.size-2 && state[@x+2][@y] == :hit
        @value += 2*hit_value
      end
    end

    if @y > 0 && state[@x][@y-1] == :hit
      @value += hit_value
      if @y > 1 && state[@x][@y-2] == :hit
        @value += 2*hit_value
      end
    end

    if @y < Board.size-1 && state[@x][@y+1] == :hit
      @value += hit_value
      if @y < Board.size-2 && state[@x][@y+2] == :hit
        @value += 2*hit_value
      end
    end
  end

  def <=>(other)
    @value <=> other.value
  end
end

class Region
  
  attr_reader :start_pos, :top, :bottom, :left, :right
  
  def initialize start_pos, state, value = :hit
    @start_pos = start_pos
    @top = start_pos.x - 1
    @bottom = start_pos.x + 1
    @left = start_pos.y - 1
    @right = start_pos.y + 1

    # Find top
    while @top >= 0
      if state[@top][start_pos.y] != value
        break
      end
      @top -= 1
    end

    # Find bottom
    while @bottom < Board.size
      if state[@bottom][start_pos.y] != value
        break
      end
      @bottom += 1
    end

    while @left >= 0
      if state[start_pos.x][@left] != value
        break
      end
      @left -= 1
    end

    while @right < Board.size
      if state[start_pos.x][@right] != value
        break
      end
      @right += 1
    end
  end
  

  def value
    size = (@bottom - @top-1) * (@right-@left-1)
    ary = [(@bottom - @start_pos.x).abs, (@top - @start_pos.x).abs, (@left - @start_pos.y).abs, (@right - @start_pos.y).abs]
    size.to_f / ((ary.max - ary.min)/2 + 1)
  end
end



class Ship
  attr_reader :x, :y, :length, :orientation

  def initialize(x, y, length, orientation)
    @x = x
    @y = y
    @length = length
    @orientation = orientation
  end

  def each_position
    return to_enum(:each_position) unless block_given?
    length.times do |index|
      case @orientation
      when :across
        yield(@x + index, @y)
      else
        yield(@x, @y + index)
      end
    end
  end

  def collision?(board)
    each_position.any? do |x, y|
      board.occupied? x, y
    end
  end

  def to_a
    [@x, @y, @length, @orientation]
  end

  def Ship.randomly_place(length, board)
    while true
      orientation = [:across, :down].sample
      candidate = Ship.new(rand(0...(Board.size)), rand(0...(Board.size)), length, orientation)
      unless candidate.collision? board
        board.add_ship candidate
        return candidate
      end
    end
  end
end

class Board
  @@size = 10

  def Board.size
    @@size
  end

  def initialize
    @occupied = {}
  end

  def add_ship(ship)
    ship.each_position do |x, y|
      @occupied[[x, y]] = ship
    end
    ship
  end

  def occupied?(x, y)
    return true unless (0...@@size) === x && (0...@@size) === y
    @occupied[[x, y]]
  end

  def ships
    @occupied.values.uniq
  end
end