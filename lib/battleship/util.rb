module Battleship
  module Util
    PLAYER_METHODS = [:name, :new_game, :take_turn]

    def find_player_classes
      Module.constants.
        select { |sym| sym.to_s =~ /Player$/ }.
        map    { |sym| Module.const_get(sym) }.
        select { |klass|
          (klass.instance_methods & PLAYER_METHODS) == PLAYER_METHODS
        }
    end
  end
end
