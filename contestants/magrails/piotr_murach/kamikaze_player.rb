class KamikazePlayer

  attr_accessor :board, :memory

  def initialize
    @board = Board.new
    @memory = Board.new
    @memory = @memory.generate
  end

  def name
    "Kamikaze Player"
  end

  def new_game
    board.set_sail
  end

  def take_turn(state, ships_remaining)
    if state == :hit
      memory[state.first, state.last] = true
      x0 = state.first + 1 < 10 ? state.first + 1 : state.first - 1
      y0 = state.last  + 1 < 10 ? state.last + 1 : state.last - 1
      x, y = x0, y0
      while memory[x, y] == true
        x0 = state.first + 1 < 10 ? state.first + 1 : state.first - 1
        y0 = state.last  + 1 < 10 ? state.last + 1 : state.last - 1
        x, y = x0, y0
      end
    else
      x, y = rand(10), rand(10)
      while memory[x, y] == true
        x, y = rand(10), rand(10)
      end
    end

    [x, y]
  end

end

class Ship

  attr_accessor :length, :x, :y, :pos

  def initialize(len)
    @length = len
    @x = rand(10)
    @y = rand(10)
    @pos = position
  end

  def generate_for(len)
    self.new length: len, x: rand(10), y: rand(10), pos: position[rand(2)]
  end

  def position
   [ :across, :vertical ][rand(2)]
  end

  def to_array
    [length, x, y, position]
  end

end

class Board

  attr_accessor :ships

  def initialize
    @ships = []
  end

  def generate
    arr = []
    (0..9).each do |x|
      (0..9).each do |y|
        arr[x] = false
      end
    end
    arr
  end

  def set_sail
    [5, 4, 3, 2, 2].each do |len|
      boat = Ship.new(len)
      while !valid?(boat = Ship.new(len)); end
      ships << boat.to_array
    end
    ships
  end

  def valid?(ship)
    if ship.pos == :across
      ship.x + ship.length - 1 < 9
    else
      ship.y + ship.length - 1 < 9
    end
  end

end
