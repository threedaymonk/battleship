module FiringPattern
  class EndGame
    FACTOR = 0.66
    def initialize(admiral, last_shot, last_shot_result, enemy_fleet)
      @sea = admiral.sea
      @initial_fleet = admiral.initial_fleet
    end

    def wants_next_shot?(last_shot, last_shot_result, enemy_fleet)
      if in_the_end_game?
        @pattern = @sea.hits.map { |hit|
          @sea.positions_around(hit, 1)
        }.
        flatten(1).
        reject { |co_ords_and_status|
          _, status = *co_ords_and_status
          status != :unknown
        }.
        map do |co_ords_and_status|
          co_ords, _ = *co_ords_and_status
          co_ords
        end
        has_next_shot?
      else
        false
      end
    end

    def has_next_shot?
      @pattern.any?
    end

    def next_shot!
      @pattern[rand(@pattern.size)]
    end

    def in_the_end_game?
      @sea.hit_count > (@initial_fleet.inject(:+) * FACTOR)
    end
  end
end