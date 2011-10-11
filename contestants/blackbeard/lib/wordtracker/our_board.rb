require_relative "board"

module Wordtracker
  class OurBoard < Wordtracker::Board

    def initialize(width, height)
      super
      @player = nil
    end
    
    def assign_player(player)
      @player = player
      player.assign_board(self)
    end
  
    def set_position(x, y)
      @boardstate[x][y] = 1
    end
  
    def state
      @boardstate
    end
    
    def valid?
      @fleet.ships.each do |ship|
        return false if !ship.one_square_clear?
      end
      true
    end
  end
end