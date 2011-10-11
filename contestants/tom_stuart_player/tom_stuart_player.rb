class PatternBasedPlayer
  def initialize
    @queue = []
    @visited = []
    @ships_remaining = [5, 4, 4, 3, 2]
  end

  def name
    "Tom Stuart Player"
  end

  def new_game
    [
      [1, 1, 5, :down],
      [6, 3, 4, :across],
      [4, 2, 3, :down],
      [5, 7, 3, :across],
      [3, 6, 2, :down]
    ]
  end

  def take_turn(state, ships_remaining)
    @queue = [] if @ships_remaining.size > ships_remaining.size
    @ships_remaining = ships_remaining
    unless @last.nil?
      if state[@last[1]][@last[0]] == :hit
        @queue.unshift(*neighbours_of(@last))
      end
    end
    @last = @queue.shift || next_step
    @visited << @last
    @last
  end

  def visit(coords)
    @last = coords
  end

  def next_step
    the_next = [0, 0]
    if @last_in_pattern
      if @last_in_pattern[0] + step_distance > 9 
        unless @last_in_pattern[1] + 1 > 9
          row = @last_in_pattern[1] + 1
          col = row % 2
          the_next = [col, row]
        end
      else
        the_next = [@last_in_pattern[0] + step_distance, @last_in_pattern[1]]
      end
    end
    @last_in_pattern = the_next
    the_next
  end

  def step_distance
    @ships_remaining.min
  end

  def neighbours_of(coords)
    north_edge = coords[1] - 1 < 0
    west_edge = coords[0] - 1 < 0
    east_edge = coords[0] + 1 > 9
    south_edge = coords[1] + 1 > 9
    neighbours = []
    neighbours << [coords[0], coords[1] + 1] unless south_edge
    neighbours << [coords[0] + 1, coords[1]] unless east_edge
    neighbours << [coords[0] - 1, coords[1]] unless west_edge
    neighbours << [coords[0], coords[1] - 1] unless north_edge
    neighbours.reject {|n| @visited.include?(n) }
  end
end
