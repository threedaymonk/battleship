class JustinSmithPlayer

  def initialize
    @probability_factor = [ 5, 4, 3, 2, 1]
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
      # Let's see which ship we killed
      ships_remaining.each do |ship|
        @prev_ships_remaining.delete_at(@prev_ships_remaining.index ship)
      end

      missing_ship_length = @prev_ships_remaining.min
      @prev_ships_remaining = ships_remaining

      if missing_ship_length.nil?
        raise "No missing ship? #{@prev_ships_remaining} <=> #{ships_remaining}"
      end
      region = Region.find_zone( @prev_move, state, missing_ship_length, :hit)
      fill_region region, :kill
    end

    # Create all of the possible positions we could play
    @prev_state = state
    (0...Board.size).each do |x|
      (0...Board.size).each do |y|
        ary << Pos.new(x, y, state, ships_remaining)
      end
    end

    #Delete the positions that have no value
    ary.delete_if {|x| x.value == 0 }
    if ary.empty?
      raise "How is this possible?"
    end

    # Permute the list so that we will get a random maximum-value item
    ary.shuffle!
    ary.sort!
    ary.reverse!

    @prev_move = ary.first
    return [ary.first.y, ary.first.x]

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
      x = pos[0]
      y = pos[1]
      state[x][y] = value
    end
  end

end


class Pos
  attr_reader :value, :x, :y
  @@state_values = { unknown: 1, hit: 10}

  def initialize(x, y, state, ships_remaining)
    @x = x
    @y = y
    @value = 0
    # It only has value if it's unknown
    if state[x][y] == :unknown
      compute_value state, ships_remaining
    end
  end

  def compute_value state, ships_remaining
    #How many of the remaining ships might possible be in this position?
    ships_remaining.each do |size|
      (0..(size-1)).each do |i|
        side1 = (1..i)
        side2 = (1..(size-1-i))
        if side1.all? {|x| (x <= @x) && @@state_values[state[@x-x][@y]] } &&
            side2.all? {|x| (@x + x < Board.size) && @@state_values[state[@x+x][@y]]}
          side1.each {|x| @value += x*@@state_values[state[@x-x][@y]]}
          side2.each {|x| @value += x*@@state_values[state[@x+x][@y]]}
        end
        if side1.all? {|y| (y <= @y) && @@state_values[state[@x][@y-y]]} &&
            side2.all? {|y| (@y + y < Board.size) && @@state_values[state[@x][@y+y]]}
          side1.each {|y| @value += y*@@state_values[state[@x][@y-y]]}
          side2.each {|y| @value += y*@@state_values[state[@x][@y+y]]}
        end
      end
    end
  end

  def <=>(other)
    @value <=> other.value
  end

  def to_s
    "<Pos: [#{@x}, #{@y}] : #{@value}>"
  end
end

class Region
  
  attr_reader :top, :bottom, :left, :right
  
  def initialize top, bottom, left, right
    @top = top
    @bottom = bottom
    @left = left
    @right = right

    [@top, @bottom, @left, @right].each do |val|
      if val < -1 || val > Board.size
        raise "Invalid: #{start_pos} #{size} #{ary.first.inspect} "
      end
    end
  end

  def intersect other
    top = @top < other.top ? other.top : @top
    bottom = @bottom > other.bottom ? other.bottom : @bottom
    left = @left < other.left ? other.left : @left
    right = @right > other.right ? other.right : @right
    Region.new top, bottom, left, right
  end

  def Region.find_zone start_pos, state, size, value = :hit
    ary = []
    (0..(size-1)).each do |i|
      side1 = (1..i)
      side2 = (1..(size-1-i))
      if side1.all? {|x| (x <= start_pos.x) && state[start_pos.x-x][start_pos.y] == value} &&
          side2.all? {|x| (start_pos.x + x < Board.size) && state[start_pos.x+x][start_pos.y] == value}
        ary << [i, :down]
      end
      if side1.all? {|y| (y <= start_pos.y) && state[start_pos.x][start_pos.y-y] == value} &&
          side2.all? {|y| (start_pos.y + y < Board.size) && state[start_pos.x][start_pos.y+y] == value}
        ary << [i, :across]
      end
    end

    if ary.length == 0
      raise "This shouldn't happen!"
    end

    region_ary = ary.map do |loc|
      if loc[1] == :across
        Region.new start_pos.x - 1, start_pos.x + 1, start_pos.y - loc[0] - 1, start_pos.y + size - loc[0]
      else loc[1] == :down
        Region.new start_pos.x - loc[0] - 1, start_pos.x + size - loc[0], start_pos.y - 1, start_pos.y + 1
      end
    end

    region_ary.inject(:intersect)

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