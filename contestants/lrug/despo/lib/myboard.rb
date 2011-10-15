module Board
  def set_available_moves
    @moves_taken = []
    @available_moves = [
      0,  2,  4,  6,  8,
      11, 13, 15, 17, 19,
      20, 22, 24, 26, 28,
      31, 33, 35, 37, 39,
      40, 42, 44, 46, 48,
      51, 53, 55, 57, 59,
      60, 62, 64, 66, 68,
      71, 73, 75, 77, 79,
      80, 82, 84, 86, 88,
      91, 93, 95, 97, 99
    ]
    @remaining_moves = 100.times.map { |x| x } - @available_moves
  end

  def last_move_was_a type
    type_at(last_x, last_y).eql? type
  end

  def type_at x, y
    @state[x][y]
  end

  def last_x
    @moves_taken.last[1]
  end

  def last_y
    @moves_taken.last[0]
  end

  def no_moves_taken?
    @moves_taken.empty?
  end

  def for_position x,y
    [y, x]
  end

  def set_state state
    @state = state
  end

  def update_moves_and_return move
    remove move
    @moves_taken << move
    move
  end

  def remove move
    @available_moves.delete(move[0]*10+move[1])
  end

  def random_move
    @available_moves = @remaining_moves if @available_moves.empty?
    @available_moves.sample.divmod 10
  end

  def hit_counts
    @state.flatten.select { |element| element == :hit }.size
  end

  def hit_orientation
    return [1, 0] if consecutive_hits_match_at 0
    return [0, 1] if consecutive_hits_match_at 1
    return [1, 1]
  end

  def consecutive_hits_match_at pos
    @moves_taken.last[pos] == @moves_taken[mlen-2][pos] and @correct_hits.length > 1
  end

  def mlen
    @moves_taken.length
  end
end
