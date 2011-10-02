$:.unshift File.expand_path("../../lib", __FILE__)
$:.unshift File.expand_path("../../players/lib", __FILE__)

require "battleship/board"
require "random_placement"

SIZE = 10
FLEET = [5, 4, 3, 3, 2]


load ARGV[0]

class_name = Module.constants.find{ |c|
  c.to_s =~ /Player$/
}
player_class = Module.const_get(class_name)

results = 100.times.map{
  player = player_class.new
  player.new_game
  board = Battleship::Board.new(SIZE, FLEET, RandomPlacement.new(FLEET, SIZE).positions)
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
