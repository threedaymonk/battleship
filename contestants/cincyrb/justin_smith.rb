class JustinSmithPlayer

  PROB = 2.0/3.0

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

    (0...Board.size).each do |x|
      (0...Board.size).each do |y|
        ary << Pos.new(x, y, state)
      end
    end

    ary.delete_if {|x| x.value == 0 }
    ary.sort!
    ary.reverse!

    #puts ary[0..10].inspect

    # Probabilistically select move over geometric distribution

    i = 0
    while true
      unless rand > PROB
        pos =  ary[i % ary.length]
        puts "State: #{state[pos.x][pos.y]}"
        puts "Pos: #{pos.inspect}"
        return [pos.y, pos.x]
      end
      i += 1
    end

  end
end


class Pos
  attr_reader :value, :x, :y

  def initialize(x, y, state)
    @x = x
    @y = y
    @value = 1
    compute_value(state)
  end

  def compute_value(state)

    # If we guessed it before, just skip it.
    if state[@x][@y] != :unknown
      @value = 0
      return
    end

    # Check column
    above = 0
    (@x-1).downto(0) do |x|
      if state[x][@y] == :unknown
        above += 1
      else
        break
      end
    end
    below = 0
    (@x+1).upto(Board.size-1) do |x|
      if state[x][@y] == :unknown
        below += 1
      else
        break
      end
    end
    # Add the smaller of the two
    @value += ((above < below) ? above : below)


    # Check row
    left = 0
    (@y-1).downto(0) do |y|
      if state[@x][y] == :unknown
        left += 1
      else
        break
      end
    end
    right = 0
    (@y+1).upto(Board.size-1) do |y|
      if state[@x][y] == :unknown
        right += 1
      else
        break
      end
    end
    # Add the smaller of the two
    @value += ((left < right) ? left : right)

    # Check neighbors for hit
    if @x > 0 && state[@x-1][@y] == :hit
      @value += 10
    end

    if @x < Board.size-1 && state[@x+1][@y] == :hit
      @value += 10
    end

    if @y > 0 && state[@x][@y-1] == :hit
      @value += 10
    end

    if @y < Board.size-1 && state[@x][@y+1] == :hit
      @value += 10
    end

  end

  def <=>(other)
    @value <=> other.value
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
      case @orientation
        when :across
          x_range = (0...(Board.size-length))
          y_range = (0...(Board.size))
        else
          x_range = (0...(Board.size-length))
          y_range = (0...(Board.size))
      end
      candidate = Ship.new(rand(x_range), rand(y_range), length, orientation)
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