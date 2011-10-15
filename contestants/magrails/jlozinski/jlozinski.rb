class JLozinskiPlayer
  def name
    "Jonathan Lozinski"
  end

  def new_game
    @my_board = init_board
    @my_ships = []
    @last_shot = nil
    @priority_targets = []
    init_ships_to_place
    place_my_ships
    @my_ships
  end

  def take_turn(state, ships_remaining)
    if @last_shot && state[@last_shot[0], @last_shot[1]] == :hit
      @priority_targets += find_possible_around(@last_shot, state)
      @priority_targets.uniq!
    else
      poss = find_possibles(state)
    end

    unless @priority_targets.empty?
      @last_shot = @priority_targets.sample(1).first || poss.sample(1).first
    else
      @last_shot = poss.sample(1).first
    end
    @last_shot
  end

  private

    @ships_to_place = []

    @my_board = []

    def init_ships_to_place
      @ships_to_place = [5,4,3,3,2].reverse!
    end

    def find_possibles(state)
      poss = []
      (0..9).each do |x|
        (0..9).each do |y|
          poss << [x,y] if state[y][x] == :unknown
        end
      end
      poss
    end

    def find_possible_around(pos, state)
      lx = pos[0]-1
      ux = pos[0]+1
      ly = pos[1]-1
      uy = pos[1]+1
      lx = [0,lx].min
      ux = [9,ux].max
      ly = [0,ly].min
      uy = [9,uy].max
      poss = []
      (lx..ux).each do |x|
        (ly..uy).each do |y|
          poss << [x,y] if state[y][x] == :unknown
        end
      end
      poss
    end

    def place_my_ships
      ship = @ships_to_place.pop
      r = Random.new
      until ship.nil?
        placed = false
        until placed do
         x = r.rand(10)
         y = r.rand(10)
         orient = [:across, :down].sample(1).first
         placed = can_place?(ship, x, y, orient)
         place_ship(ship, x, y, orient) if placed
        end
        ship = @ships_to_place.pop
      end
    end

    def init_board
      Array.new(10) do
        Array.new(10, ' ')
      end
    end
  
    def can_place?(ship, x, y, orientation)
      cx = x
      cy = y
      case orientation
        when :across
          ship.times do
            return false if @my_board[cx][cy] != " "
            cx += 1
            return false if cx >= 10
          end
          return true
        when :down
          ship.times do
            return false if @my_board[cx][cy] != " "
            cy += 1
            return false if cy >= 10
          end
          return true
      end
   end

   def place_ship(ship, x, y, orientation)
      @my_ships << [x,y,ship,orientation]
      cx = x
      cy = y
      case orientation
        when :across
          ship.times do
            @my_board[cx][cy] = "S"
            cx += 1
          end
        when :down
          ship.times do
            @my_board[cx][cy] = "S"
            cy += 1
          end
      end

   end
end
