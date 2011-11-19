module Randomiser
  class << self
    def coordinate
      rand 10
    end

    def start_of_ship_with_length length
      rand(10 - length)
    end

    def direction
      [:across, :down][rand(2)]
    end
  end
end

class ShipPlacer
  def initialize
    @taken = []
  end

  def carrier
    ship_of_length 5
  end

  def battleship
    ship_of_length 4
  end

  def sub
    ship_of_length 3
  end

  def cruiser
    ship_of_length 3
  end

  def destroyer
    ship_of_length 2
  end

  private

  def ship_of_length length
    direction = Randomiser.direction
    across_coord = Randomiser.coordinate
    along_coord = Randomiser.start_of_ship_with_length length
    try_again = false
    taken = @taken
    if direction == :across
      x, y = along_coord, across_coord
      (y..y+length).each do |y|
        try_again ||= @taken.include? [x, y]
        @taken << [x, y]
      end
    else
      x, y = across_coord, along_coord
      (x..x+length).each do |x|
        try_again ||= @taken.include? [x, y]
        @taken << [x, y]
      end
    end
    if try_again
      ship_of_length(length)
    else
      @taken = taken
      [x, y, length, direction]
    end
  end
end

class KerryPlayer
  def initialize
    @tried = []
  end

  def name
    "Kerry"
  end

  def new_game
    placer = ShipPlacer.new
    [placer.carrier, placer.battleship, placer.sub, placer.cruiser, placer.destroyer]
  end

  def take_turn state, ships_remaining
    x, y = Randomiser.coordinate, Randomiser.coordinate
    if @tried.include? [x, y]
      take_turn state, ships_remaining
    else
      @tried << [x, y]
      [x, y]
    end
  end
end
