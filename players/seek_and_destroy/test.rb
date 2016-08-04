require "minitest/autorun"
require_relative "./player.rb"
class SeekAndDestroyTest < MiniTest::Unit::TestCase

  def setup
    @player = SeekAndDestroy.new
    @ships_remaining = [5, 4, 3, 3, 2]
    @state = []

    def @player.get_random_position
      return [0, 0]
    end

    10.times do |row|
      column = []
      10.times do |thing|
        column << :unknown
      end
      @state << column
    end
  end

  def test_that_untrained_player_will_attack_randomly
    turn = @player.take_turn(@state, @ships_remaining)
    assert_equal(turn, [0, 0])
  end

  def test_that_when_a_hit_is_registered_then_it_is_saved
    @player.take_turn(@state, @ships_remaining)
    @state[0][0] = :hit
    @player.take_turn(@state, @ships_remaining)
    assert_equal(@player.new_hit, [0])
  end
end
