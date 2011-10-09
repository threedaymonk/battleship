require "minitest/autorun"
require "battleship/game"
require "mocha"

class GameTest < MiniTest::Unit::TestCase
  include Battleship

  class MockPlayer
    def initialize(positions, plays, name, history=[])
      @positions = positions
      @plays = plays
      @name = name
      @history = history
    end

    def new_game
      @history << [@name, :new_game]
      @positions
    end

    def take_turn(board_state, ships_remaining)
      @history << [@name, :take_turn, board_state, ships_remaining]
      @plays.shift
    end

    def inspect(*args)
      "<Player #{@name}>"
    end
  end

  def test_should_call_new_game_for_each_player_in_turn
    history = []
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [], "A", history),
      MockPlayer.new([[0, 0, 2, :across]], [], "B", history)
    ]
    Game.new(2, [2], *players)
    assert_equal [["A", :new_game], ["B", :new_game]], history
  end

  def test_should_call_take_turn_with_known_board_state
    history = []
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [[0, 0], [0, 1], [1, 1]], "A", history),
      MockPlayer.new([[0, 1, 2, :across]], [[0, 0], [1, 1], [0, 1]], "B", history)
    ]
    game = Game.new(2, [2], *players)
    2.times do
      history.shift
    end
    6.times do
      game.tick
    end
    expected = [
      ["A", :take_turn, [[:unknown, :unknown], [:unknown, :unknown]]],
      ["B", :take_turn, [[:unknown, :unknown], [:unknown, :unknown]]],
      ["A", :take_turn, [[:miss,    :unknown], [:unknown, :unknown]]],
      ["B", :take_turn, [[:hit,     :unknown], [:unknown, :unknown]]],
      ["A", :take_turn, [[:miss,    :unknown], [:hit,     :unknown]]],
      ["B", :take_turn, [[:hit,     :unknown], [:unknown, :miss   ]]],
    ]
    assert_equal expected, history.map{ |h| [h[0], h[1], h[2]] }
  end

  def test_should_tell_players_about_ships_remaining
    history = []
    players = [
      MockPlayer.new([[0, 0, 2, :across], [0, 1, 1, :across]], [[0, 0], [0, 1], [1, 1]], "A", history),
      MockPlayer.new([[0, 0, 2, :down  ], [1, 0, 1, :down  ]], [[0, 0], [1, 1], [0, 1]], "B", history)
    ]
    game = Game.new(2, [2, 1], *players)
    2.times do
      history.shift
    end
    6.times do
      game.tick
    end
    expected = [
      ["A", [2, 1]],
      ["B", [2, 1]],
      ["A", [2, 1]],
      ["B", [2, 1]],
      ["A", [1]],
      ["B", [2, 1]]
    ]
    assert_equal expected, history.map{ |h| [h[0], h[3]] }
  end

  def test_should_fail_first_player_with_illegal_fleet
    history = []
    players = [
      MockPlayer.new([], [], "A", history),
      MockPlayer.new([], [], "B", history)
    ]
    game = Game.new(2, [2], *players)
    assert_equal players[1], game.winner
  end

  def test_should_fail_first_player_with_overlapping_fleet
    players = [
      MockPlayer.new([[0, 0, 2, :across], [0, 0, 2, :across]], [], "A"),
      MockPlayer.new([[0, 0, 2, :across], [0, 1, 2, :across]], [], "B")
    ]
    game = Game.new(2, [2, 2], *players)
    assert_equal players[1], game.winner
  end

  def test_should_fail_player_with_invalid_fleet
    history = []
    players = [
      MockPlayer.new(nil, [], "A", history),
      MockPlayer.new([[0, 0, 2, :across]], [], "B", history)
    ]
    game = Game.new(2, [2], *players)
    assert_equal players[1], game.winner
  end

  def test_should_fail_player_with_invalid_position
    history = []
    players = [
      MockPlayer.new([nil], [], "A", history),
      MockPlayer.new([[0, 0, 2, :across]], [], "B", history)
    ]
    game = Game.new(2, [2], *players)
    assert_equal players[1], game.winner
  end

  def test_should_have_no_winner_at_start_of_valid_game
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [], "A"),
      MockPlayer.new([[0, 1, 2, :across]], [], "B")
    ]
    game = Game.new(2, [2], *players)
    assert_nil game.winner
  end

  def test_should_fail_player_that_plays_an_invalid_move
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [nil], "A"),
      MockPlayer.new([[0, 1, 2, :across]], [[0,0]], "B")
    ]
    game = Game.new(2, [2], *players)
    game.tick
    assert_equal players[1], game.winner
  end

  def test_should_fail_player_that_plays_an_impossible_move
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [[3,3]], "A"),
      MockPlayer.new([[0, 1, 2, :across]], [[0,0]], "B")
    ]
    game = Game.new(2, [2], *players)
    game.tick
    assert_equal players[1], game.winner
  end

  def test_should_have_no_winner_until_all_boats_are_sunk
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [[0, 0], [0, 1], [1, 1]], "A"),
      MockPlayer.new([[0, 1, 2, :across]], [[0, 0], [1, 1], [0, 1]], "B")
    ]
    game = Game.new(2, [2], *players)
    assert_nil game.winner
    4.times do
      game.tick
    end
    assert_nil game.winner
  end

  def test_should_report_winner_as_first_player_to_sink_opponents_boats
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [[0, 0], [0, 1], [1, 1]], "A"),
      MockPlayer.new([[0, 1, 2, :across]], [[0, 0], [1, 1], [0, 1]], "B")
    ]
    game = Game.new(2, [2], *players)
    assert_nil game.winner
    5.times do
      game.tick
    end
    assert_equal players[0], game.winner
  end

  def test_should_report_player_names
    players = [
      MockPlayer.new([], [], "A"),
      MockPlayer.new([], [], "B")
    ]
    players[0].stubs(:name).returns("Foo")
    players[1].stubs(:name).returns("Bar")
    game = Game.new(2, [], *players)

    assert_equal ["Foo", "Bar"], game.names
  end

  def test_should_report_current_board
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [[0, 0], [0, 1]], "A"),
      MockPlayer.new([[0, 1, 2, :across]], [[0, 0], [1, 1]], "B")
    ]
    game = Game.new(2, [2], *players)
    4.times do
      game.tick
    end
    expected = [
      [[:hit,     :unknown], [:unknown, :miss   ]],
      [[:miss,    :unknown], [:hit,     :unknown]],
    ]
    assert_equal expected, game.report
  end

  def test_should_report_current_ships_remaining
    players = [
      MockPlayer.new([[0, 0, 2, :across]], [[0, 1], [1, 1]], "A"),
      MockPlayer.new([[0, 1, 2, :across]], [[0, 0], [1, 1]], "B")
    ]
    game = Game.new(2, [2], *players)
    4.times do
      game.tick
    end
    expected = [[2], []]
    assert_equal expected, game.ships_remaining
  end

end
