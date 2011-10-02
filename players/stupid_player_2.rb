class Stupid2Player
  def name
    "Stupid Player 2"
  end

  def new_game
    [
      [5, 0, 5, :across],
      [5, 1, 4, :across],
      [5, 2, 3, :across],
      [5, 3, 3, :across],
      [5, 4, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)
    [rand(10), rand(10)]
  end
end
