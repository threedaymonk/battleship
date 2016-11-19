require 'yaml'
require_relative '../lib/game_state'
require_relative '../lib/model'

class SeekAndDestroy

  SNAPSHOTS_DIR = "snapshots"

  def name
    "Seek and Destroy"
  end

  def initial_ship_positions
    [
      [0, 0, 5, :across],
      [0, 1, 4, :across],
      [0, 2, 3, :across],
      [0, 3, 3, :across],
      [0, 4, 2, :across]
    ]
  end

  def new_game
    Model.setup_training
    initial_ship_positions
  end

  def take_turn(state, ships_remaining)
    Model.update_model(state)
    if Model.model_trained
      model = Model.build_model
      return unflatten(model.each_with_index.max[1])
    else
      random_hit
    end
  end

  def unflatten(index)
    row = index/10
    column = index % 10
    [row, column]
  end

  def random_hit
    [rand(10), rand(10)]
  end
end
