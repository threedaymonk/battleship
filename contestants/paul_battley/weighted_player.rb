require "random_placement"
require "convolution"

class PaulBattleyWeightedPlayer
  WINDOW = 4

  def name
    "Paul Battley's Weighted Player"
  end

  def new_game
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
    last = last_result(@last_state, state)
    @history << last if last
    @last_state = state

    xy = if @history.reverse[0, WINDOW].any?{ |x| x == :hit }
      follow(state)
    else
      explore(state)
    end
    @free.delete xy

    xy
  end

private
  def last_result(last_state, this_state)
    return nil unless last_state
    last_state.flatten.zip(this_state.flatten).find{ |a,b|
      a != b
    }[1]
  end

  KERNEL_EXPLORE = [
    [ 0, 0, 1, 0, 0 ],
    [ 0, 0, 3, 0, 0 ],
    [ 1, 3, 0, 3, 1 ],
    [ 0, 0, 3, 0, 0 ],
    [ 0, 0, 1, 0, 0 ]
  ]

  def explore(state)
    convolution = Convolution.new(state, KERNEL_EXPLORE){ |v| v == :unknown ? 1 : 0 }
    @free.sort_by{ |x, y|
      -convolution.at(x, y)
    }.first
  end

  KERNEL_FOLLOW = [
    [ 0,  0,  1,  0,  0 ],
    [ 0, -1,  3, -1,  0 ],
    [ 1,  3,  0,  3,  1 ],
    [ 0, -1,  3, -1,  0 ],
    [ 0,  0,  1,  0,  0 ]
  ]

  def follow(state)
    convolution = Convolution.new(state, KERNEL_FOLLOW){ |v| v == :hit ? 1 : 0 }
    @free.sort_by{ |x, y|
      -convolution.at(x, y)
    }.first
  end
end
