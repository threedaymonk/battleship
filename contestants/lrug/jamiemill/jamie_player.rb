require 'jamie/positioner'
require 'jamie/strategy'

class JamiePlayer
  def initialize
    @positioner = Jamie::Positioner.new
    @strategy = Jamie::Strategy.new
  end

  def name
    "Jamie Mill Player"
  end

  def new_game
    @positioner.get_setup
  end

  def take_turn(state, ships_remaining)
    @strategy.get_next_shot(state, ships_remaining)
  end
end
