#require 'logger'
#$log = Logger.new('/tmp/player.log')
#$log.level = Logger::DEBUG

class HarryPlayer

  def name
    "gc"
  end

  def new_game
    @position = [0, rand(10)]
    [
      [0, 0, 5, :across],
      [0, 1, 4, :across],
      [0, 2, 3, :across],
      [0, 3, 3, :across],
      [0, 4, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)
    position = @position
    find_hits(state).each do |hit|
      targets = find_neighbours(state, hit).select { |n| n.first == :unknown }
      if targets.length > 0
        position = targets.first[1]
        break
      end
    end
    #$log.debug "seq_pos: #@position, pos: #{position}"
    @position = next_checker_position(state) if position == @position
    position
  end

private

  def next_checker_position(state)
    width, height = state.first.length, state.length
    x, y = @position
    x += 2
    x, y = 1 + -(x % width), y + 1 if x >= width
    x, y = 1 + -x, 0 if y >= height
    [x, y]
  end

  def find_hits(state)
    hit_locations = []

    state.each_with_index do |row, y|
      row.each_with_index do |value, x|
        hit_locations << [x, y] if value == :hit
      end
    end

    hit_locations
  end

  def valid_position?(state, position)
    return false if position[0] < 0 || position[0] >= state.length
    return false if position[1] < 0 || position[1] >= state[0].length
    true
  end

  def find_neighbours(state, position)
    neighbours = []
    height, width = state.length, state.first.length

    try_neighbour = lambda do |x, y|
      if x >= 0 && x < width && y >= 0 && y < height
        neighbours << [state[y][x], [x, y]]
      end
    end

    try_neighbour.call position[0],     position[1] - 1
    try_neighbour.call position[0] + 1, position[1]
    try_neighbour.call position[0],     position[1] + 1
    try_neighbour.call position[0] - 1, position[1]

    neighbours
  end

end
