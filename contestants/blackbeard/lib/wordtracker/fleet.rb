module Wordtracker
  class Fleet
    attr_reader :board, :ships
    
    def initialize(ship_lengths)
      @board = nil
      @ships = []
      ship_lengths.each do |ship|
        @ships << Ship.new(ship, self)
      end
    end
    
    def assign_board(board)
      @board = board
    end
    
    def to_a(testing=false)
      result = []
      @ships.each do |ship|
        result << ship.to_a
      end
      result
    end
  end 
end