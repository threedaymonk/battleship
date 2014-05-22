$:.unshift File.expand_path("../../lib", __FILE__)
require "battleship/game"
require "battleship/console_renderer"
require "battleship/util"
require "stringio"
require "digest/sha1"
require "forwardable"
require "drb"

WINS_REQUIRED = 10
MOVE_DELAY = 0.0
ROUND_DELAY = 0.0


#WINS_REQUIRED = 3
#MOVE_DELAY = 0.2
#ROUND_DELAY = 3
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
    @object.stop(@secret)
  end
end

begin
  DRb.start_service

  player_server = File.expand_path("../player_server.rb", __FILE__)

  players = []

  2.times.each do |i|
    path = ARGV[i]
    port = PORT + i
    secret = Digest::SHA1.hexdigest("#{Time.now}#{rand}#{i}")
    system %{ruby #{player_server} "#{path}" #{port} #{secret} &}
    Battleship::Util.wait_for_socket('0.0.0.0', port)
    players << PlayerClient.new(secret, DRbObject.new(nil, "druby://0.0.0.0:#{port}"))
  end

  winners = []

  max_rounds = 2*WINS_REQUIRED-1
  max_rounds.times do |i|
    stderr = ""
    $stderr = StringIO.new(stderr)

    game = Battleship::Game.new(10, [2, 3, 3, 4, 5], *players)
    renderer = Battleship::DeluxeConsoleRenderer.new
    $stdout << renderer.render(game)
    $stdout << stderr

    until game.winner
      t0 = Time.now
      game.tick
      time_taken = Time.now - t0
      $stdout << renderer.render(game)
      $stdout << stderr
      sleep [MOVE_DELAY - time_taken, 0].max
    end

    puts "", "#{game.winner.name} won round #{i+1}!"

    winners << game.winner.name

    sleep ROUND_DELAY

    winner0_count = winners.count{|x| x == winners[0] }
    
    # break if the first round winner has sufficient wins
    if winner0_count >= WINS_REQUIRED
      break
    end
    
    # break if the first round winner would lose, even if she wins the remaining rounds
    if(winner0_count + max_rounds - i - 1) < WINS_REQUIRED
      break
    end
    
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
  players.each &:kill
end
