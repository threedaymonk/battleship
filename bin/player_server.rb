$:.unshift File.expand_path("../../lib", __FILE__)
require "drb"
require "forwardable"
require "battleship/util"

module Battleship
  class PlayerServer
    include Battleship::Util
    extend Forwardable

    def initialize
      @player_class = find_player_classes.first
      @player = @player_class.new
    end

    def_delegators :@player, :name, :take_turn

    def new_game
      @player = @player_class.new
      @player.new_game
    end
  end

  class ValidatingServer
    include DRbUndumped

    ValidationError = Class.new(RuntimeError)

    def initialize(secret, object, port)
      @secret = secret
      @object = object
      DRb.start_service "druby://0.0.0.0:#{port}", self
    end

    def method_missing(m, *args)
      validate!(args.shift)
      @object.__send__(m, *args)
    end

    def stop(secret)
      validate!(secret)
      DRb.stop_service
    end

  private
    def validate!(secret)
      raise ValidationError unless secret == @secret
    end
  end
end

lambda{ |path, port, secret|
  $:.unshift File.join(File.dirname(path), "lib")
  load path

  Battleship::ValidatingServer.new(
    secret, Battleship::PlayerServer.new, port
  )
}.call(*ARGV)

DRb.thread.join
