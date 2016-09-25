require "minitest/autorun"
require_relative "./clumper.rb"
class ClumperTest < MiniTest::Unit::TestCase

  def setup
    @state = []

    10.times do |row|
      column = []
      10.times do |thing|
        column << :unknown
      end
      @state << column
    end
    @clumper = Clumper.new
  end

  def test_that_no_hits_gives_no_clumps
    found = @clumper.clump(@state)
    expected = []
    assert_equal(expected, found)
  end

  def test_that_one_hit_gives_one_clump
    @state[0][0] = :hit
    found = @clumper.clump(@state).size
    assert_equal(1, found)
  end

  def test_that_clump_returned_by_single_hit_has_coordinate_of_hit
    @state[0][0] = :hit
    found = @clumper.clump(@state)[0]
    expected = [[0, 0]]
    assert_equal(expected, found)
  end

  def test_that_one_clump_is_returned_when_there_are_two_adjacent_hits
    @state[0][0] = :hit
    @state[0][1] = :hit
    found = @clumper.clump(@state).size
    assert_equal(1, found)
  end

  def test_that_clump_returned_by_two_adjacent_hits_has_coordinates_of_hits
    @state[0][0] = :hit
    @state[0][1] = :hit
    found = @clumper.clump(@state)[0]
    assert_equal([[0, 0], [0, 1]], found)
  end
end
