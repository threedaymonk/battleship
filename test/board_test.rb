require "minitest/autorun"
require "battleship/board"

class BoardTest < MiniTest::Unit::TestCase
  include Battleship

  def test_should_accept_valid_initial_layout
    board = Board.new(4, [4, 2], [[0, 0, 4, :across], [0, 1, 2, :down]])
    assert board.valid?
  end

  def test_should_reject_nil_initial_layout
    board = Board.new(4, [2], nil)
    refute board.valid?
  end

  def test_should_reject_initial_layout_containing_nil_position
    board = Board.new(4, [2], [nil])
    refute board.valid?
  end

  def test_should_reject_initial_layout_with_badly_formed_position_1
    board = Board.new(4, [2], [[0, 0, 2]])
    refute board.valid?
  end

  def test_should_reject_initial_layout_with_badly_formed_position_2
    board = Board.new(4, [2], [["a", "b", "c", "e"]])
    refute board.valid?
  end

  def test_should_reject_initial_layout_with_missing_ships
    board = Board.new(4, [4, 2], [[0, 0, 4, :across]])
    refute board.valid?
  end

  def test_should_reject_initial_layout_with_extra_ships
    board = Board.new(4, [4], [[0, 0, 4, :across], [0, 1, 2, :down]])
    refute board.valid?
  end

  def test_should_reject_initial_layout_with_wrong_combination_of_ships
    board = Board.new(4, [4, 2], [[0, 0, 4, :across], [0, 1, 3, :across]])
    refute board.valid?
  end

  def test_should_reject_initial_layout_with_ships_outside_range
    board = Board.new(4, [4], [[2, 0, 4, :across]])
    refute board.valid?
  end

  def test_should_report_hit
    board = Board.new(4, [4], [[0, 1, 4, :across]])
    assert_equal :hit, board.try([2, 1])
  end

  def test_should_still_report_hit_if_try_is_repeated
    board = Board.new(4, [4], [[0, 1, 4, :across]])
    board.try([2, 1])
    assert_equal :hit, board.try([2, 1])
  end

  def test_should_report_miss
    board = Board.new(4, [4], [[0, 1, 4, :across]])
    assert_equal :miss, board.try([2, 2])
  end

  def test_should_report_invalid_move_for_nil
    board = Board.new(4, [4], [[0, 1, 4, :across]])
    assert_equal :invalid, board.try(nil)
  end

  def test_should_report_invalid_move_for_nil_element
    board = Board.new(4, [4], [[0, 1, 4, :across]])
    assert_equal :invalid, board.try([nil, nil])
  end

  def test_should_report_invalid_move_for_out_of_range_coordinate
    board = Board.new(4, [4], [[0, 1, 4, :across]])
    assert_equal :invalid, board.try([4, 4])
  end

  def test_should_still_report_miss_if_try_is_repeated
    board = Board.new(4, [4], [[0, 1, 4, :across]])
    board.try([2, 2])
    assert_equal :miss, board.try([2, 2])
  end

  def test_should_record_hits_and_misses
    board = Board.new(2, [2], [[0, 0, 2, :across]])
    board.try([0, 0])
    board.try([0, 1])
    assert_equal [[:hit, :unknown], [:miss, :unknown]], board.report
  end

  def test_should_not_be_sunk_if_any_part_of_ship_remains
    board = Board.new(2, [2, 1], [[0, 0, 2, :across], [0, 1, 1, :across]])
    board.try([0, 0])
    board.try([0, 1])
    refute board.sunk?
  end

  def test_should_be_sunk_if_no_part_of_any_ship_remains
    board = Board.new(2, [2, 1], [[0, 0, 2, :across], [0, 1, 1, :across]])
    board.try([0, 0])
    board.try([1, 0])
    board.try([0, 1])
    assert board.sunk?
  end

  def test_should_list_ships_still_in_play_at_start
    board = Board.new(2, [2, 1], [[0, 0, 2, :across], [0, 1, 1, :across]])
    assert_equal [2, 1], board.ships_remaining
  end

  def test_should_list_ships_still_in_play_after_a_hit
    board = Board.new(2, [2, 1], [[0, 0, 2, :across], [0, 1, 1, :across]])
    board.try([0, 0])
    assert_equal [2, 1], board.ships_remaining
  end

  def test_should_list_ships_still_in_play_after_a_sinking
    board = Board.new(2, [2, 1], [[0, 0, 2, :across], [0, 1, 1, :across]])
    board.try([0, 1])
    assert_equal [2], board.ships_remaining
  end
end
