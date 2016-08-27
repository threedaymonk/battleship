class StateReader
  def read_board(state, ships_remaining)
    if state.flatten.include?(:hit)
      return [Ship.new]
    else
      return []
    end
  end
end
