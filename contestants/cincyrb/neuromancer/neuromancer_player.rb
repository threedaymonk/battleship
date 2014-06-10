require 'battleship_board'
require 'fleet_specifications'
require 'fleet_placement_strategies'
require 'bombs_away_strategies'

class NeuromancerPlayer
  SHIP_LENGTHS = [2, 3, 3, 4, 5]

  def initialize
    @board = BattleshipBoard.new(10)
    @fleet_specifications = [
      ValidShipsFleetSpecification.new,
      NonOverlappingFleetSpecification.new,
      AllOnBoardFleetSpecification.new(@board)
    ]
    @fleet_placement_strategy = RandomFleetPlacementStrategy.new(@board, @fleet_specifications)
    @bombs_away_strategy = RandomBombsAwayStrategy.new(@board)
  end

  def name
    "Neuromancer"
  end

  def new_game
    @fleet_placement_strategy.arrange_fleet(SHIP_LENGTHS)
  end

  def take_turn(state, ships_remaining)
    @board.update!(state, ships_remaining)
    return @bombs_away_strategy.fire
    if hit = find_hit(state)
      find_unknown_neighbor(state, hit) || random_shot(state)
    else
      random_shot(state)
    end
  end

  private

  def random_shot(state)
    loop do
      x = rand(0..9)
      y = rand(0..9)
      return [x, y] if state[y][x] == :unknown
    end
  end

  def find_hit(state)
    for y in 0..9
      for x in 0..9
        return [x, y] if state[y][x] == :hit
      end
    end
    nil
  end

  def find_unknown_neighbor(state, point)
    px, py = point
    for y_offset in -1..1
      for x_offset in -1..1
        next if x_offset == 0 and y_offset == 0
        x = px + x_offset
        next if x < 0 or x > 9
        y = py + y_offset
        next if y < 0 or y > 9
        return [x, y] if state[y][x] == :unknown
      end
    end
    nil
  end

  def classify(state, &condition)
    result = []
    for y in 0..9
      for x in 0..9
        result << [x, y] if condition.call(state[y][x])
      end
    end
    result
  end
end

