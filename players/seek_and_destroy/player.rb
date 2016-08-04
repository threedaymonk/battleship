class SeekAndDestroy

  attr_reader :new_hit

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

  def initialize
    @past_hits = []
    @new_hit = nil
  end

  def take_turn(state, ships_remaining)
    flat_state = state.flatten
    hit_locations = flat_state.size.times.select {|i| flat_state[i] == :hit}
    @new_hit = hit_locations - @past_hits
    @past_hits = hit_locations
    get_random_position
  end

  def get_random_position
    [rand(10), rand(10)]
  end
end
