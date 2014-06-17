require 'battleship_board'

# SPECIFICATION that is satisfied by fleets containing the correct allotment of ships.
class ValidShipsFleetSpecification
  def satisfied_by?(fleet)
    fleet.all? {|ship| valid_ship?(ship)}
    fleet.map {|x, y, length, direction| length}.sort == [2,3,3,4,5]
  end

  private

  def valid_ship?(ship)
    x, y, length, direction = ship
    x.is_a?(Integer) && y.is_a?(Integer) && [:down, :across].include?(direction)
  end
end

# SPECIFICATION that is satisfied by fleets containing ships that do not overlap.
class NonOverlappingFleetSpecification
  def satisfied_by?(fleet)
    points = fleet.inject([]) {|memo, ship| memo + points(ship)}
    points.uniq == points
  end

  private

  def points(ship)
    x, y, length, direction = ship
    case direction
    when :across
      (x...x+length).inject([]) { |memo, n| memo << [n, y] }
    when :down
      (y...y+length).inject([]) { |memo, n| memo << [x, n] }
    end
  end
end

# SPECIFICATION that is satisfied by fleets containing ships that are all within the confines of the board.
class AllOnBoardFleetSpecification
  def initialize(board)
    @board = board
  end

  def satisfied_by?(fleet)
    fleet.all? {|ship| @board.on_board?(ship)}
  end
end

