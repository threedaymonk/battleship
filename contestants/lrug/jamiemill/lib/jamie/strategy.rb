require 'jamie/seek_strategies'
require 'jamie/nav'
require 'jamie/state_inspections'

module Jamie
  class Strategy

    include Jamie::StateInspections

    attr_writer :state
    attr_writer :ships_remaining

    def get_next_shot(state, ships_remaining)
      @state = state
      @ships_remaining = ships_remaining

      #TODO: calculate impossible points and subtract from this lot
      points_to_try = [
        super_likely_points,
        (likely_points - not_so_likely_points),
        #SeekStrategies::CheckerBoard.points,
        SeekStrategies::CircularSweep.points,
        SeekStrategies::DiagonalTLtoBR.points,
        SeekStrategies::DiagonalTRtoBL.points,
        unknown_points
      ].inject(:+).uniq
      points_to_try = (points_to_try - known_points) - impossible_points
      points_to_try.first
    end

    # Finds :unknown points immediately above, left, right, and below
    # :hit points

    def likely_points
      points = []
      hit_points.each do |point|
        points = points + Nav.around(point)
      end
      points.uniq - known_points
    end

    def in_line_with_hit_neighbours(point)
      [:up,:right,:down,:left].each do |dir|
        if check_point(Nav.send(dir,point)) == :hit && check_point(Nav.send(dir,point,2)) == :hit
          return true
        end
      end
      false
    end

    def super_likely_points
      points = likely_points.reject do |point|
        !in_line_with_hit_neighbours?(point)
      end
      points.uniq - known_points
    end

    # find points alongside lines
    def not_so_likely_points
      unknown_points.reject do |point|
        !adjacent_to_ship?(point)
      end.uniq
    end

    def impossible_points
      unknown_points.reject do |point|
        !(part_of_max_unknown_line(point) < @ships_remaining.min)
      end
    end

    def part_of_max_unknown_line(point)
      maxvert = 1;
      [:up,:down].each do |dir|
        i=1
        loop do
          other_point = Nav.send(dir,point,i)
          if check_point(other_point) == :unknown
            maxvert = maxvert + 1
            i = i+1
          else
            break
          end
        end
      end

      maxhoriz = 1;
      [:right,:left].each do |dir|
        i=1
        loop do
          other_point = Nav.send(dir,point,i)
          if check_point(other_point) == :unknown
            maxhoriz = maxhoriz + 1
            i = i+1
          else
            break
          end
        end
      end

      [maxvert,maxhoriz].max

    end


  end
end
