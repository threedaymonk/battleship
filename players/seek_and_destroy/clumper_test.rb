require "minitest/autorun"
require_relative "./clumper.rb"
class ClumperTest < MiniTest::Unit::TestCase

  def test_that_no_hits_gives_no_clumps
    clumper = Clumper.new
    found = clumper.clump
    expected = []
    assert_equal(expected, found)
  end

end
