module Wordtracker
  class Ship
    attr_accessor :x, :y, :orientation, :sunk
    attr_reader :length, :fleet

    def initialize(length, fleet)
      @x, @y, @length, @orientation = 0, 0, length, :across
      @fleet = fleet
    end

    def place(board)
      @x, @y = board.random_free_spot.to_a
      until one_square_clear?
        switch_orientation
        @x, @y = board.random_free_spot.to_a
      end
      offset = 0
      @length.times do
        if @orientation == :across
          board.set_position(@x, @y+offset)
        else
          board.set_position(@x+offset, @y)
        end
        offset += 1
      end
      [@y, @x, @length, @orientation]
    end
    
    def switch_orientation
      @orientation = (@orientation == :across) ? :down : :across
    end
    
    def on_edge?
      board = @fleet.board
    end
    
    def one_square_clear?
      offset = 0
      @length.times do
        if @orientation == :across
          if offset == 0
            return false unless (
              @fleet.board.get_position(@x-1, @y) == :unknown and
              @fleet.board.get_position(@x+1, @y) == :unknown and
              @fleet.board.get_position(@x, @y-1) == :unknown
            )
          elsif offset == (@length - 1)
            return false unless (
              @fleet.board.get_position(@x-1, @y+offset) == :unknown and
              @fleet.board.get_position(@x+1, @y+offset) == :unknown and
              @fleet.board.get_position(@x, @y+1+offset) == :unknown
            )
          else
            return false unless (
              @fleet.board.get_position(@x-1, @y+offset) == :unknown and
              @fleet.board.get_position(@x+1, @y+offset) == :unknown
            )
          end
        else
          if offset == 0
            return false unless (
              @fleet.board.get_position(@x, @y-1) == :unknown and
              @fleet.board.get_position(@x, @y+1) == :unknown and
              @fleet.board.get_position(@x-1, @y) == :unknown
            )
          elsif offset == (@length - 1)
            return false unless (
              @fleet.board.get_position(@x+offset, @y+1) == :unknown and
              @fleet.board.get_position(@x+offset, @y-1) == :unknown and
              @fleet.board.get_position(@x+1+offset, @y) == :unknown
            )
          else
            return false unless (
              @fleet.board.get_position(@x+offset, @y+1) == :unknown and
              @fleet.board.get_position(@x+offset, @y-1) == :unknown
            )
          end
        end
        offset += 1
      end
      return true
    end
    
    def sunk?
      @sunk
    end

    def sunk=(sunk)
      @sunk = sunk
    end
    
    def to_a
      [@y, @x, @length, @orientation]
    end
  end
end