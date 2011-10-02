$:.unshift(File.expand_path("../../lib", __FILE__))
require "battleship/game"
require "battleship/console_renderer"
require "stringio"
require "digest/sha1"
require "forwardable"
require "drb"

DELAY = 0.2
PORT = 4432

class PlayerClient
  extend Forwardable

  def initialize(secret, object)
    @secret = secret
    @object = object
  end

  def method_missing(m, *args)
    args.unshift(@secret)
    @object.__send__(m, *args)
  end

  def kill
    @object.die(@secret)
  end
end

begin
  DRb.start_service

  player_server = File.expand_path("../player_server.rb", __FILE__)

  players = 2.times.map{ |i|
    path = ARGV[i]
    port = PORT + i
    secret = Digest::SHA1.hexdigest("#{Time.now}#{rand}#{i}")
    system %{ruby #{player_server} "#{path}" #{port} #{secret} &}
    sleep 1
    PlayerClient.new(secret, DRbObject.new(nil, "druby://localhost:#{port}"))
  }

  winners = []

  3.times do |i|
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

    puts "", "#{game.winner.name} won round #{i+1}!"

    winners << game.winner.name

    sleep 3

    break if i == 1 && winners[0] == winners[1]

    players.reverse!
  end

  puts
  winners.each_with_index do |name, i|
    puts "Round #{i+1}. #{name}"
  end

  players.each &:kill

rescue Exception => e
  $stderr = STDERR
  raise e
ensure
  players.each &:kill if players
end
