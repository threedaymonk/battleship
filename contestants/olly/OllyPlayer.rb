require 'set'
require 'matrix'

class OllyPlayer
  BoardSize = 10
  Infinity = (1.0/0)

  class Board
    def initialize(current_state, ships_remaining)
      row = Array.new(BoardSize, 0)
      @board = Array.new(BoardSize) { row.dup }
      calculate_scores(current_state, ships_remaining)
    end

    def next_target
      highest_scoring_coordinates.shuffle.first
    end

    protected
    def [](x, y)
      if in_bounds?(x, y)
        @board[x][y]
      else
        0
      end
    end

    def []=(x, y, score)
      if in_bounds?(x, y)
        @board[x][y] = score
      end
    end

    def coordinates_by_score
      coordinates_by_score = {}
      @board.each.with_index do |row, y|
        row.each.with_index do |score, x|
          coordinates_by_score[score] ||= []
          coordinates_by_score[score] << [x, y]
        end
      end
      coordinates_by_score
    end

    def highest_scoring_coordinates
      highest_scoring_coordinates = coordinates_by_score
      highest_scoring_coordinates[highest_scoring_coordinates.keys.sort.last]
    end

    private
    def calculate_scores(current_state, ships_remaining)
      current_state.each.with_index do |row, x|
        row.each.with_index do |state, y|
          case state
          when :miss
            self[x, y] = -Infinity
          when :hit
            self[x, y] = -Infinity
            self[x, y - 1] += 10
            self[x, y + 1] += 10
            self[x - 1, y] += 10
            self[x + 1, y] += 10
          when :unknown
            ships_remaining.uniq!
            ships_remaining.each do |ship_size|
              if ((x - y) % ship_size == 0)
                self[x, y] += 1
              end
            end
          end
        end
      end
    end
  
    def in_bounds?(x, y)
      bounds = (0...BoardSize)
      bounds.include?(x) && bounds.include?(y)
    end
  end

  class Region
    def self.coordinates(top_left, bottom_right)
      xs, ys = top_left.zip(bottom_right)

      cells = Set.new
      Range.new(*xs).each do |x|
        Range.new(*ys).each do |y|
          cells << Vector[x, y]
        end
      end
      new(cells)
    end

    def initialize(cells)
      @cells = Set.new(cells)
    end

    attr_reader :cells

    def -(region)
      Region.new(self.cells - region.cells)
    end

    def can_place?(size)
      placements(size).any?
    end

    def placement(size)
      placements(size).to_a.shuffle.first
    end

    private
    def placements(size)
      positions = {
        across: Vector[size - 1, 0],
        down:   Vector[0, size - 1]
      }

      Enumerator.new do |yielder|
        cells.each do |start_cell|
          positions.each do |position, end_transform|
            if cells.include?(start_cell + end_transform)
              yielder.yield [*start_cell, size, position]
            end
          end
        end
      end
    end
  end

  def name
    "Olly Legg"
  end

  def new_game
    regions = []
    center = Region.coordinates([3, 3], [6, 6])
    regions << center
    regions << Region.coordinates([0, 0], [4, 4]) - Region.new([[0, 0]]) - center # Top Left
    regions << Region.coordinates([5, 0], [9, 4]) - Region.new([[9, 9]]) - center # Top Right
    regions << Region.coordinates([0, 5], [4, 9]) - Region.new([[0, 9]]) - center # Bottom Left
    regions << Region.coordinates([5, 5], [9, 9]) - Region.new([[9, 0]]) - center # Bottom Right

    ship_sizes = [5, 4, 3, 3, 2]
    ships = ship_sizes.map do |ship_size|
      regions.shuffle
      region = regions.detect {|region| region.can_place?(ship_size) }
      regions.delete(region)
      region.placement(ship_size)
    end

    return ships
  end

  def take_turn(state, ships_remaining)
    board = Board.new(state, ships_remaining)
    board.next_target
  end
end
