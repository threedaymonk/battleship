class Player

  def initialize
    @turns = []
    @initial_turn = [5,5]
    @last_ships_remaining = 5
    @last_state = false
    @board = []
  end

  def name
    "@Tobscher"
  end

  def new_game

    @board = []
    #orientations = 5.times .map { random_position }

    @board = [
      [0,0,5,:across],
      [0,5,4,:across],
      [0,9,3,:across],
      [3,9,3,:across],
      [6,9,2,:across]
    ]

    #size = [5,4,3,3,2]

    #@board << 5.times { get_new_ship size.shift }
  end

  def get_new_ship
    ship = get_random_ship

    while has_collision ship
      ship = get_random_ship
    end
  end

  def get_random_ship
    2.times.map { rand(5) }
  end

  def has_collision ship
  end

  def take_turn(state, ships_remaining)
    turn = @initial_turn
    unless @turns.length == 0
      if @last_state == :hit
        if @ships_remaining < ships_remaining
          # change the location
          while @turns.include? turn
            turn = change_location
          end
        else
          # try to hit the ship again
          while @turns.include? turn
            turn = hit_again
          end
        end
      else
        #try another location
        while @turns.include? turn
          turn = change_location
        end
      end
    end

    @turns << turn

    @last_ships_remaining = ships_remaining

    turn
  end

  def change_location
    2.times.map { Random.rand(10) }
  end

  def hit_again()
    turn = @turns.last

    x = 100 + Random.rand(10) % 2
    y = 100 + Random.rand(10) % 2
    y = 100 + Random.rand(10) % 2

    turn[0] = turn[0] + 1
    turn[1] = turn[1] + 1
  end

  def random_position
    if 100 + Random.rand(10) % 2 == 0
      :across
    else
      :down
    end
  end
end
