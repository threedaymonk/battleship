require "minitest/autorun"
require "battleships/console_renderer"
require "stringio"
require "mocha"

class ConsoleRendererTest < MiniTest::Unit::TestCase
  include Battleships

  def test_should_clear_terminal_and_render_names_and_current_guesses
    game = stub("game")
    game.stubs(:names).returns(["Albert", "Beatrix"])
    game.stubs(:report).returns([
      [[:hit,     :unknown], [:unknown, :miss   ]],
      [[:miss,    :unknown], [:hit,     :unknown]],
    ])
    expected = "\e[2J" +
               "Albert  | Beatrix\n" +
               "        |\n" +
               "X .     | ~ . \n" +
               ". ~     | X . \n" +
    actual = ""
    ConsoleRenderer.new(StringIO.new(actual)).render(game)
    assert_equal expected, actual
  end
end

