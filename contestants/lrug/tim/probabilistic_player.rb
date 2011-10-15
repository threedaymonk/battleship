require 'grid'

class ProbabilisticPlayer

  def new_game
    Grid.choose_positions 
  end
  
 
  def take_turn(state, ships_remaining)
    Grid.choose_shot(state) 
  end

  def name
    "mistertim"
  end

end
