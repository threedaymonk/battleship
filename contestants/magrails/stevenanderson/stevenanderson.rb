class StevenAndersonPlayer
  def initialize
     @grid = []
     (0..9).each { |i| @grid[i] = [false]*10 }
     @locations = []
     @moves_taken = []
     @to_look_at = []
  end

  def name
    "STEVEN ANDERSON"
  end

  def new_game
    [5,4,3,3,2].each do |length|
        position = nil
        until position && valid?(position)
          position = generate(length)
            
        end

        add position
    end
    @locations
  end

  def take_turn(state, ships_remaining)
    did_i_hit = @last_move && state[@last_move[1]][@last_move[0]] == :hit
    move = nil

    if did_i_hit
        add_to_look_at(*@last_move)
    end

    if !@to_look_at.empty?
        move = @to_look_at.pop
    else
        until move && !@moves_taken.include?(move)
            move = [rand(10), rand(10)]
        end
    end

    @moves_taken << move
    @last_move = move
    
  end

  def add_to_look_at(x,y)
    @to_look_at << [x + 1, y] if x < 9 && !@moves_taken.include?( [x + 1, y])
    @to_look_at << [x - 1, y] if x > 0 && !@moves_taken.include?( [x - 1, y])
    @to_look_at << [x, y + 1] if y < 9 && !@moves_taken.include?( [x, y + 1])
    @to_look_at << [x, y - 1] if y > 0 && !@moves_taken.include?( [x, y - 1])
  end

  private
 
  def add(position)
    @locations << position
    for_ship(position) do |x,y| 
        @grid[x][y] = true
    end
  end

  def generate(length)
     x, y, orientation = rand(10), rand(10), (rand(2) == 1 ? :across : :down)
     [x, y, length, orientation]
  end

  def for_ship(position)
    x,y,length,orientation = position
    length.times do
       yield x, y
       if orientation == :across
         x = x + 1
       else
         y = y + 1
       end
    end
  end

  def valid?(position)
    for_ship(position) do |x,y|
      return false if (x > 9 || y > 9 || @grid[x][y])
    end
    true
  end
end
