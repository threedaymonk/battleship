require "random_placement"
require "convolution"

class WeightedPlayer
  def name
    "Weighted Player"
  end

  def new_game
    @played = []
    @free = 10.times.map{ |y|
      10.times.map{ |x|
        [x, y]
      }
    }.flatten(1)
    @last_state = nil
    @history = []

    RandomPlacement.new([5, 4, 3, 3, 2], 10).positions
  end

  def take_turn(state, ships_remaining)
    last = last_result(state)
    @history << last if last

    if @history.reverse[0, 4].any?{ |x| x == :hit }
      xy = follow(state)
    else
      xy = explore(state)
    end
    @last_state = state
    @played << xy
    @free.delete xy
    xy
  end

  def last_result(state)
    return nil unless @last_state
    @last_state.flatten.zip(state.flatten).find{ |a,b|
      a != b
    }[1]
  end

private
  def explore(state)
    convolution = Convolution.new(state, KERNEL){ |v| v == :unknown ? 1 : 0 }
    @free.sort_by{ |x, y|
      -convolution.at(x, y)
    }[0,4].sample
  end

  KERNEL = [
    [ 0, 0, 1, 0, 0 ],
    [ 0, 0, 2, 0, 0 ],
    [ 1, 2, 0, 2, 1 ],
    [ 0, 0, 2, 0, 0 ],
    [ 0, 0, 1, 0, 0 ]
  ]

  def follow(state)
    convolution = Convolution.new(state, KERNEL){ |v| v == :hit ? 1 : 0 }
    @free.sort_by{ |x, y|
      -convolution.at(x, y)
    }.first
  end
end
