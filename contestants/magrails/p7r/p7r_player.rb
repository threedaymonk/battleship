class Player
  attr_accessor :my_board
  attr_accessor :my_ships
  attr_accessor :opp_board
  attr_accessor :opp_ships
  
  def initalize
    @my_board = [[:unknown] * 10] * 10
    @my_ships = [5, 4, 3, 3, 2]
    @prob_grid = [[0] * 10] * 10
  end
    
  def name
    "@p7r the Pirate arrrrr!"
  end
  
  def new_game
    positions = [
      [
        [5, 5, 5, :across],
        [5, 7, 4, :across],
        [1, 1, 3, :down],
        [3, 1, 3, :down],
        [5, 1, 2, :down]
    ],
      [
        [5, 1, 5, :across],
        [5, 3, 4, :across],
        [0, 6, 3, :down],
        [2, 6, 3, :down],
        [4, 6, 2, :down]
    ],
      [
        [5, 1, 5, :across],
        [5, 3, 4, :across],
        [1, 5, 3, :across],
        [1, 6, 3, :across],
        [1, 8, 2, :across]
    ],
      [
        [1, 1, 5, :across],
        [1, 3, 4, :across],
        [5, 5, 3, :across],
        [5, 6, 3, :across],
        [5, 8, 2, :across]
    ],
      [
        [1, 1, 5, :down],
        [3, 1, 4, :down],
        [4, 6, 3, :down],
        [6, 6, 3, :down],
        [8, 6, 2, :down]
    ],
      [
        [6, 1, 5, :down],
        [8, 1, 4, :down],
        [0, 6, 3, :down],
        [2, 6, 3, :down],
        [4, 6, 2, :down]
    ]
    ]
    return positions[rand(positions.size)]
  end
  
  def take_turn(state, ships)
    @opp_board = state
    @opp_ships = ships
    @test_x, @test_y = nil, nil
    unless empty_board?
      for x in 0..9
        for y in 0..9
          @test_x, @test_y = x, y if check_if_hit(x, y) 
        end
      end
    end
    while check_if_hit(@test_x, @test_y) || check_if_miss(@test_x, @test_y) || @test_x.nil? || @test_y.nil?
      x, y = rand(10), rand(10)
      check_if_hit(x, y) ? (@test_x, @test_y = rand(3)-1, rand(3)-1) : (@test_x, @test_y = rand(10), rand(10))
    end
    return [@test_x, @test_y]
  end
  
  def check_if_hit(x, y)
    return true if x.nil? || y.nil? || x < 0 || y < 0
    @opp_board[y][x] == :hit
  end
  
  def check_if_miss(x, y)
    return true if x.nil? || y.nil? || x < 0 || y < 0
    @opp_board[y][x] == :miss
  end
  
  def empty_board?
    for x in 0..9
      for y in 0..9
        return false if check_if_hit(x, y) || check_if_miss(x, y)
      end
    end
    return true
  end
  
end