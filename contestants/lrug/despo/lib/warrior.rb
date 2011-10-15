require_relative 'myboard'
require_relative 'ships'

class BattleshipWarrior
  include Board

  def initialize
    @correct_hits = []
    @guesses = []
    @ships = Ships.new
    set_available_moves
  end

  def set_remaining_ships ships
    @ships.update_with ships
    @guesses = [] if hit_locations_match_ships?
    @correct_hits = [] if hit_locations_match_ships?
  end

  def hit_locations_match_ships?
    hit_counts == @ships.sunk_cells
  end

  def next_move
    return select_random_move if no_moves_taken?
    @correct_hits << [last_x, last_y] if last_move_was_a :hit
    return try_to_guess_move
  end

  def select_random_move
    update_moves_and_return random_move
  end

  def try_to_guess_move
    move = guess_target_position
    return update_moves_and_return move unless move.nil?

    return select_random_move
  end

  def guess_target_position
    increment_range.each do |x_incr, y_incr|
      add_guess_if_valid(last_x+x_incr, last_y+y_incr)
    end if last_move_was_a :hit

    guess_position
  end

  def guess_position
    @guesses.pop
  end

  def increment_range
    [[0,1], [0,-1], [1, 0], [-1,0]].map { |x, y| [x*hit_orientation[0], y*hit_orientation[1]] }
  end

  def add_guess_if_valid x, y
    add_guessed_target for_position(x, y) if position_not_taken_or_invalid? x, y
  end

  def add_guessed_target position
    @guesses.push(position).uniq!
  end

  def position_not_taken_or_invalid? x, y
    !@moves_taken.include? for_position(x, y) and (0..9).include? y and (0..9).include? x
  end
end
