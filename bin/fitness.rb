$:.unshift File.expand_path("../../lib", __FILE__)
$:.unshift File.expand_path("../../players/lib", __FILE__)
$:.unshift File.expand_path("../../data", __FILE__)

require "battleship/board"
require "battleship/util"
require "sample_boards"
require "parallel"

SIZE = 10
FLEET = [5, 4, 3, 3, 2]

module Stats
  def sum(&blk)
    map(&blk).inject { |sum, element| sum + element }
  end

  def mean
    (sum.to_f / length.to_f)
  end

  def median
    sort[length / 2]
  end

  def variance
    m = mean
    sum { |i| ( i - m )**2 } / length
  end

  def std_dev
    Math.sqrt(variance)
  end
end

path = ARGV[0]
$:.unshift File.join(File.dirname(path), "lib")
load path

player_class = Battleship::Util.find_player_classes.first

results = Parallel.map(Battleship::SAMPLE_BOARDS) { |positions|
  player = player_class.new
  player.new_game
  board = Battleship::Board.new(SIZE, FLEET, positions)
  shots = 0
  until board.sunk?
    board.try(player.take_turn(board.report, board.ships_remaining).dup)
    shots += 1
  end
  shots
}

results.extend(Stats)

puts "mean: %.1f" % results.mean
puts "median: %d" % results.median
puts "min: %d" % results.min
puts "max: %d" % results.max
puts "sd: %.1f" % results.std_dev
