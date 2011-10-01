$:.unshift(File.expand_path("../lib", __FILE__))
$:.unshift(File.expand_path("../players/lib", __FILE__))
require "battleship/game"
require "battleship/console_renderer"
require "stringio"

DELAY = 0.2

Dir[File.expand_path("../players/*.rb", __FILE__)].each do |path|
  load path
end

begin
  players = ARGV[0,2].map{ |s| Module.const_get(s).new }
  stderr = ""
  $stderr = StringIO.new(stderr)

  game = Battleship::Game.new(10, [2, 3, 3, 4, 5], *players)
  renderer = Battleship::DeluxeConsoleRenderer.new
  $stdout << renderer.render(game)
  $stdout << stderr

  until game.winner
    game.tick
    $stdout << renderer.render(game)
    $stdout << stderr
    sleep DELAY
  end

  puts "#{game.winner.name} won!"
rescue Exception => e
  $stderr = STDERR
  raise e
end
