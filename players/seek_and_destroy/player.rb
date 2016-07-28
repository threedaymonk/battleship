class SeekAndDestroy
  def name
    "Seek and Destroy"
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
    get_random_position
  end

  def get_random_position
    [rand(10), rand(10)]
  end

  def get_past_hits
    return [0, 0]
  end
end
