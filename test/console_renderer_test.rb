require "minitest/autorun"
require "battleship/console_renderer"
require "stringio"
require "mocha"

class ConsoleRendererTest < MiniTest::Unit::TestCase
  include Battleship

  def test_should_clear_terminal_and_render_names_and_current_guesses
    game = stub("game")
    game.stubs(:names).returns(["Albert", "Beatrix"])
    game.stubs(:report).returns([
      [[:hit,     :unknown], [:unknown, :miss   ]],
      [[:miss,    :unknown], [:hit,     :unknown]],
    ])
    game.stubs(:ships_remaining).returns([[1], [2, 1]])
    expected = <<END
\e[2J\e[HAlbert

X .   X 
. ~   

Beatrix

~ .   X X 
X .   X 
END
    actual = ConsoleRenderer.new.render(game)
    assert_equal expected, actual
  end
end

