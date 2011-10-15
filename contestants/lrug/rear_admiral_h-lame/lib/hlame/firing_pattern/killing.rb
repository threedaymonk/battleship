module FiringPattern
  class Killing
    def initialize(admiral, last_shot, last_shot_result, enemy_fleet)
      @sea = admiral.sea
      @starting_point = last_shot
      @known_fleet = enemy_fleet
      @biggest = @known_fleet.sort.last
      @current_pattern = []
    end

    def wants_next_shot?(last_shot, last_shot_result, enemy_fleet)
      if (@starting_point == last_shot) && (last_shot_result == :hit)
        self.generate_firing_pattern
        true
      else
        if @known_fleet.size > enemy_fleet.size
          false
        else
          update_firing_pattern(last_shot, last_shot_result)
          has_next_shot?
        end
      end
    end

    def has_next_shot?
      @current_pattern.any?
    end

    def next_shot!
      @current_pattern.delete_at(rand(@current_pattern.size))
    end

    def generate_firing_pattern
      all = @sea.positions_around(@starting_point, @biggest - 1)
      @current_pattern = split_and_filter_positions(all, @starting_point)
    end
    
    def update_firing_pattern(last_shot, last_shot_result)
      if last_shot_result == :miss
        all = @sea.positions(*@current_pattern)
        @current_pattern = split_and_filter_positions(all, @starting_point)
      end
    end
    
    protected

    def split_and_filter_positions(positions, center)
      b_across, a_across, b_down, a_down = *split_into_before_and_after_across_and_down(positions, center)

      b_across = filter_horizontal_misses_close_to_center(b_across, center)
      a_across = filter_horizontal_misses_close_to_center(a_across, center)
      b_down = filter_vertical_misses_close_to_center(b_down, center)
      a_down = filter_vertical_misses_close_to_center(a_down, center)

      pattern = (b_across + a_across + b_down + a_down).select { |co_ord_and_state| 
        _, state = *co_ord_and_state
        state == :unknown
      }.map do |co_ord_and_state|
        co_ord, _ = *co_ord_and_state
        co_ord
      end
      pattern || []
    end

    def split_into_before_and_after_across_and_down(all, center)
      across, down = split(all) { |x,y| y == center.last }
      b_across, a_across = split(across) { |x,y| x < center.first }
      b_down, a_down = split(down) { |x,y| y < center.last }
      [b_across, a_across, b_down, a_down]
    end

    def split(all)
      all.partition do |co_ord_and_state|
        co_ord, _ = *co_ord_and_state
        x, y = *co_ord
        yield x, y
      end
    end

    def filter_vertical_misses_close_to_center(positions, center)
      filter_misses_close_to_center(positions, center, :last)
    end

    def filter_horizontal_misses_close_to_center(positions, center)
      filter_misses_close_to_center(positions, center, :first)
    end

    def filter_misses_close_to_center(positions, center, co_ord)
      sorted = in_order(positions, center, co_ord)
      closest_miss_idx = closest_miss(sorted)
      if closest_miss_idx.nil?
        sorted
      else
        sorted[0...closest_miss_idx]
      end
    end

    def in_order(positions, center, co_ord)
      return [] if positions.empty?
      sorted = positions.sort { |a,b| a.first.send(co_ord) <=> b.first.send(co_ord) }
      sorted.reverse! if sorted.first.first.send(co_ord) != center.send(co_ord) + 1
      sorted
    end

    def closest_miss(positions)
      states = positions.map {|c_a_s| c_a_s.last}
      closest_miss = states.index(:miss)
    end
  end
end
