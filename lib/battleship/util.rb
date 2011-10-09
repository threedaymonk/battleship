require "socket"

module Battleship
  module Util
    PLAYER_METHODS = [:name, :new_game, :take_turn]

    def find_player_classes
      Module.constants.
        select { |sym| sym.to_s =~ /Player$/ }.
        map    { |sym| Module.const_get(sym) }.
        select { |klass|
          methods = klass.instance_methods.collect { |m| m.to_sym }
          (methods & PLAYER_METHODS) == PLAYER_METHODS
        }
    end

    if RUBY_PLATFORM =~ /linux/i
      def wait_for_socket(host, port, timeout=1)
        socket  = Socket.new(:INET, :STREAM)
        address = Socket.pack_sockaddr_in(port, host)
        optval = [timeout, 0].pack("l_2")
        socket.setsockopt :SOCKET, :RCVTIMEO, optval
        socket.setsockopt :SOCKET, :SNDTIMEO, optval

        loop do
          begin
            socket.connect(address)
            return
          rescue SystemCallError => e
          end
        end
      end
    else
      def wait_for_socket(*args)
        sleep 1
      end
    end

    extend self
  end
end
