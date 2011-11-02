class GrahamPlayer
  def initialize	
	  @x=0
	  @y=0
	  @advance = 3
	  @last_turn = []
	  @on_a_roll = false
	  @direction_forward = true
  end
 
  def name
    "Graham Hadgraft"
  end

  def new_game
    [
      [rand(5), 0, 5, :across],
      [rand(6), 4, 4, :across],
      [rand(7), 5, 3, :across],
      [rand(7), 6, 3, :across],
      [rand(8), 8, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)
  	if @last_turn[0] != nil && last_turn(state) == :hit
  		@x += 1	
  		@on_a_roll = true
  	elsif @last_turn[0] != nil && @on_a_roll == true && last_turn(state) == :miss
		@x -= 2
		@on_a_roll = false
 
  	else
  		@x += @advance
  	end
  	
  	check_valid_coords(@x, @y)
    check_if_shot(@x,@y, state)
    
    @last_turn = [@x, @y]
    
  end
  
  private
  def last_turn(state)
	state[@last_turn[1]][@last_turn[0]]
  end
  
  def check_valid_coords(x,y)
  	 if @x > 9
    	@x -= 10
    	@y += 1
    end
    
    if @y > 9
    	@y=0
    end
  end
  
  def check_if_shot (x, y, state)
  	while state[y][x] == :miss || state[y][x] == :hit
  		if @direction_forward == true
	  		x += 1
		else
			x -= 1
		end
		  		
		if x > 9
    		x -= 10
    		y += 1
    	end
    
    	if y > 9
    		y=0
    	end
    	@x = x
    	@y = y
	end  
  end
end
