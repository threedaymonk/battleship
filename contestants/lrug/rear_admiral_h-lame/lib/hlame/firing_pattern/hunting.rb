module FiringPattern
  class Hunting
    def initialize(admiral, last_shot, last_shot_result, enemy_fleet)
      @sea = admiral.sea
      @current_pattern = []
    end

    def wants_next_shot?(last_shot, last_shot_result, enemy_fleet)
      true
    end

    def has_next_shot?
      true
    end

    def next_shot!
      shot = self.fire_at_will
      if !@sea.unknowns.include? shot
        next_shot!
      else
        shot
      end
    end

    protected

    def fire_at_will
      @current_pattern = self.firing_pattern if @current_pattern.empty?
      @current_pattern.delete_at(rand(@current_pattern.size))
    end

    def guess
      @sea.random_position(:unknown)
    end

    def firing_pattern(based_on = self.guess)
      x_c, y_c = *based_on

      10.times.map do |row|
        row_y = row - y_c
        row_x = x_c + row_y
        row_x =
          if row_x > 10
            row_x - 12
          elsif row_x < -1
            row_x + 12
          else
            row_x
          end
        firing_pattern_row(row_x, row)
      end.flatten(1)
    end

    def firing_pattern_row(for_x, for_y)
      row_xs = [-2,-1,0,1,2].map { |m| for_x + (4*m) }.reject{ |x| (x < 0) || (x > 9)}
      row_xs.map {|x| [x, for_y]}
    end
  end
end
