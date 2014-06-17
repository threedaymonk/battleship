module FleetPlacementStrategy
  class Base
    def initialize(board, fleet_specifications)
      @board = board
      @fleet_specifications = fleet_specifications
    end

    def arrange_fleet(ship_lengths)
      try_count = 0
      loop do
        fleet = do_arrange_fleet(ship_lengths)
        return fleet if satisfies_specifications?(fleet)
      end
    end

    def satisfies_specifications?(fleet)
      @fleet_specifications.all? {|spec| spec.satisfied_by?(fleet)}
    end
  end

  class Random < Base
    def do_arrange_fleet(ship_lengths)
      ship_lengths.map { |length|
        [@board.x_range.to_a.sample, @board.y_range.to_a.sample, length, [:across, :down].sample]
      }
    end
  end
end
