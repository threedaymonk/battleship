require 'battleship_board'
require 'fleet_specifications'
require 'fleet_placement_strategy'
require 'bombs_away_strategy'

class NeuromancerPlayer
  SHIP_LENGTHS = [2, 3, 3, 4, 5]

  def initialize
    @board = BattleshipBoard.new(10)
    @fleet_specifications = [
      ValidShipsFleetSpecification.new,
      NonOverlappingFleetSpecification.new,
      AllOnBoardFleetSpecification.new(@board)
    ]
    @fleet_placement_strategy = FleetPlacementStrategy::Random.new(@board, @fleet_specifications)
    @bombs_away_strategy = BombsAwayStrategy::ProbabilityDensity.new(@board)
  end

  def name
    "Neuromancer"
  end

  def new_game
    @fleet_placement_strategy.arrange_fleet(SHIP_LENGTHS)
  end

  def take_turn(state, ships_remaining)
    @board.update!(state, ships_remaining)
    @bombs_away_strategy.fire
  end
end

