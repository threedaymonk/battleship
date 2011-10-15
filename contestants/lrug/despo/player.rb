require_relative 'lib/warrior'

class HumanPlayer
  def name
    "@despo"
  end

  def new_game
    @warrior = BattleshipWarrior.new
    [
      [9, 3, 5, :down],
      [6, 0, 4, :across],
      [2, 6, 3, :down],
      [3, 0, 3, :down],
      [0, 7, 2, :down]
    ]
  end

  def take_turn(state, ships_remaining)
    @warrior.set_state state
    @warrior.set_remaining_ships ships_remaining

    @warrior.next_move
  end
end
