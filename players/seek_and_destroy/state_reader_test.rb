require "minitest/autorun"
require_relative "./state_reader.rb"
require_relative "./ship.rb"
class StateReaderTest < MiniTest::Unit::TestCase

  def setup
    @state_reader = StateReader.new
    @ships_remaining = [5, 4, 3, 3, 2]
    @state = []

    10.times do |row|
      column = []
      10.times do |thing|
        column << :unknown
      end
      @state << column
    end
  end

  def test_that_when_state_reader_is_called_with_all_unknown_it_returns_no_ships
    expected = []
    found = @state_reader.read_board(@state, @ships_remaining)
    assert_equal(expected, found)
  end

  def test_that_when_state_reader_is_called_with_one_hit_it_returns_one_object
    expected = [Ship.new]
    @state[0][0] = :hit
    found = @state_reader.read_board(@state, @ships_remaining)
    assert_equal(1, found.size)
    assert_equal(Ship, found[0].class)
  end

  def test_that_when_state_reader_is_called_with_one_hit_it_returns_a_ship
    expected = [Ship.new]
    @state[0][0] = :hit
    found = @state_reader.read_board(@state, @ships_remaining)
    assert_equal(Ship, found[0].class)
  end
end
