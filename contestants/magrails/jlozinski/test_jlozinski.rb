require "rubygems"
require "test/unit"

require './jlozinski.rb'

class TestJLozinskiPlayer < Test::Unit::TestCase
  def setup
    @player = JLozinskiPlayer.new
  end

  def test_board
    p @player.new_game
  end
end
