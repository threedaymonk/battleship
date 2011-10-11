module Wordtracker
  class Move
    attr_accessor :outcome, :sunk_ship
    
    def initialize(y, x, outcome = :unknown)
      set_position(y, x)
      sunk_ship = false
      @outcome = outcome
    end
    
    def hit?
      @outcome == :hit
    end
    
    def miss?
      @outcome == :miss
    end
    
    def y
      @position[:y]
    end
    
    def x
      @position[:x]
    end
    
    def set_position(y, x)
      @position = {:y => y, :x => x}
    end
    
    def coordinates(as_hash=false)
      as_hash ? @position : @position.map{|a,b|b}
    end
    
    def to_a
      [x,y]
    end
    
    def on_board?
      x >= 0 && x < 10 && y >= 0 && y < 10
    end
  end
end