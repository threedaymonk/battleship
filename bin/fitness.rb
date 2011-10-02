$:.unshift File.expand_path("../../lib", __FILE__)
$:.unshift File.expand_path("../../players/lib", __FILE__)
$:.unshift File.expand_path("../../data", __FILE__)

require "battleship/board"
require "battleship/util"
require "sample_boards"

SIZE = 10
FLEET = [5, 4, 3, 3, 2]

load ARGV[0]

player_class = Battleship::Util.find_player_classes.first

results = Battleship::SAMPLE_BOARDS.map{ |positions|
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

mean   = results.inject(&:+) / results.length
median = results.sort[results.length / 2]

puts "mean: %d  median: %d  min: %d  max: %d" % [mean, median, results.min, results.max]
