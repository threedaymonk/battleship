module Wordtracker
  
  class Board
    attr_reader :width, :height, :fleet, :player, :boardstate
    
    def initialize(width, height)
      @width, @height = width, height
      @boardstate = []
      @height.times { @boardstate << [:unknown] * @width }
      @fleet = nil
    end

    def assign_fleet(fleet)
      @fleet = fleet
      fleet.assign_board(self)
    end
    
    def update_outcome(move)
      @boardstate[move.y][move.x] = move.outcome
    end
    
    def state=(state)
      @boardstate = state
    end
    
    def random_free_spot
      y, x = rand(@width), rand(@height)
      until @boardstate[y][x] == :unknown
        y, x = rand(@width), rand(@height)        
      end
      Move.new(y, x)
    end
    
    def number_of_unknown_spaces
      unknowns = 0
      @boardstate.each{|row| unknowns += row.select {|a| a == :unknown}.length}
      unknowns
    end
  
    def get_position(y, x)
      return nil if (
        x < 0 or
        x >= @width or
        y < 0 or
        y >= @height
      )
      @boardstate[y][x]
    end
    
    def render
      output = "\n\t0 1 2 3 4 5 6 7 8 9\n\n\n"
      count = -1
      @boardstate.each do |row|
        output += "#{count += 1}\t"
        row.each do |square|
          case square
          when 1
            output += "# "
          when :miss
            output += "O "
          when :hit 
            output += "x "
          else
            output += ". "
          end
        end
        output += "\n"
      end
      puts output
    end  
  end
end