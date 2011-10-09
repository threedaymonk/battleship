module Battleship
  class Board
    
    def initialize(size, expected_fleet, positions)
      @size = size
      @expected_fleet = expected_fleet
      @fleet = expand_positions(positions)
      @board = expand_board(@fleet)
    end

    def valid?
      valid_fleet?(@fleet) && valid_layout?(@fleet)
    end

    def try(xy)
      return :invalid unless valid_move?(xy)
      @board[xy] = [:ship, :hit].include?(@board[xy]) ? :hit : :miss
    end

    def report
      (0 ... @size).map{ |y|
        (0 ... @size).map{ |x|
          state = @board[[x, y]]
          [:hit, :miss].include?(state) ? state : :unknown
        }
      }
    end

    def sunk?
      @board.none?{ |_, state| state == :ship }
    end

    def ships_remaining
      @fleet.select{ |ship|
        ship.any?{ |xy| @board[xy] != :hit }
      }.map{ |ship|
        ship.length
      }.sort.reverse
    end

  private
    def expand_board(fleet)
      fleet.flatten(1).inject({}){ |board, xy|
        board.merge(xy => :ship)
      }
    end

    def valid_move?(move)
      return false unless move.is_a?(Enumerable)
      move.all?{ |e| (0 ... @size).include?(e) }
    end

    def valid_layout?(fleet)
      occupied = {}
      fleet.each do |ship|
        ship.each do |xy|
          if xy.any?{ |a| a < 0 || a >= @size }
            return false
          elsif occupied[xy]
            return false
          else
            occupied[xy] = true
          end
        end
      end
    end

    def valid_fleet?(fleet)
      fleet.map(&:length).sort == @expected_fleet.sort
    end

    def expand_positions(positions)
      return [] unless positions.is_a?(Enumerable)
      positions.map{ |p| expand_position(*p) }
    rescue ArgumentError
      []
    end

    def expand_position(x, y, length, direction)
      dx, dy = direction == :across ? [1, 0] : [0, 1]
      (0 ... length).map{ |i| [x + i * dx, y + i * dy] }
    end
  end
end
