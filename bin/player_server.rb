require "drb"
require "forwardable"

module Battleship
  class PlayerServer
    extend Forwardable
    METHODS = [:name, :new_game, :take_turn]

    def initialize
      class_name = Module.constants.find{ |c| is_player?(c) }
      @player = Module.const_get(class_name).new
    end

    def_delegators :@player, *METHODS

    # Ick. Dirty. Is there a cleaner way?
    def die
      DRb.stop_service
    end
  
  private
    def is_player?(class_name)
      class_name.to_s =~ /Player$/ &&
        (Module.const_get(class_name).instance_methods && METHODS) == METHODS
    end
  end

  class ValidatingProxy
    include DRbUndumped

    ValidationError = Class.new(RuntimeError)

    def initialize(secret, object)
      @secret = secret
      @object = object
    end

    def method_missing(m, *args)
      secret = args.shift
      if secret == @secret
        @object.__send__(m, *args)
      else
        raise ValidationError
      end
    end
  end
end

lambda{ |path, port, secret|
  $:.unshift File.join(File.dirname(path), "lib")
  load path

  client = Battleship::ValidatingProxy.new(secret, Battleship::PlayerServer.new)

  DRb.start_service "druby://localhost:#{port}", client
}.call(*ARGV)

DRb.thread.join
