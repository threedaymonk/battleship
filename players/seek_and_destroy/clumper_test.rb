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
end
