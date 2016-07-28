require "minitest/autorun"
require_relative "./player.rb"
class SeekAndDestroyTest < MiniTest::Unit::TestCase

  def test_that_untrained_player_will_attack_randomly
    player = SeekAndDestroy.new

    ships_remaining = [5, 4, 3, 3, 2]
    state = []

    10.times do |row|
      column = []
      10.times do |thing|
        column << :unknown
      end
      state << column
    end

    def player.get_random_position
      return [0, 0]
    end

    turn = player.take_turn(state, ships_remaining)
    assert_equal(turn, [0, 0])
  end
end
