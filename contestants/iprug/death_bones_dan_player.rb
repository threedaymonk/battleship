class DeathBonesDanPlayer
  
  def initialize
    @taken_positions = []
    @positions = []
    
    @shots = []
  end
 
  def log(message)
    File.open('debug.log', 'a') { |f| f.write("#{Time.now} - #{message}\n") }
  end
 
  def init_taken
    (0..9).each do |x|
      @taken_positions[x] = []
      (0..9).each do |y|
        @taken_positions[x][y] = 0
      end
    end
  end
  
  def print_grid
    
  end
  
  def reserve_position (x,y,length,orientation)
    
    if orientation == :across 
      (x..length).each do |p|
        @taken_positions[p][y] = 1
      end
    else
      (y..length).each do |p|
        @taken_positions[x][p] = 1
      end      
    end
    
  end
  
  def has_space (x,y,length,orientation)
    
    if orientation == :across 
      (x..length).each do |p|
        return false if @taken_positions[p][y] == 1
      end
    else
      (y..length).each do |p|
        return false if @taken_positions[x][p] = 1 
      end      
    end
    
    true
    
  end
  
  def generate_player_positions
    
    # initialise taken grid
    init_taken
    
    ship_lengths = [5,4,3,3,2]
    
    ship_lengths.each do |z|
      
      upperbound = (10 - z)
      
      # upperbound = (10 - z)
      
      x = rand(upperbound)
      y = rand(upperbound)
      
      orientation = :across
      
      placed = false
      
      while !placed
        
        orientation = orientation == :across ? :down : :across
        
        x = rand(upperbound)
        y = rand(upperbound)
        
        # check ship position
        if has_space(x,y,z,orientation)
        
          @positions << [x,y,z,orientation]
          reserve_position x,y,z,orientation
          
          placed = true
        
        end
      
      end 
      
    end
    
    log @positions.inspect
    
    @positions
    
  end 
  
  def generate_static_positions
    
     [
        [0, 0, 5, :across],
        [0, 1, 4, :across],
        [0, 2, 3, :across],
        [0, 3, 3, :across],
        [0, 4, 2, :across]
      ]
    
  end
  
  # battleship methods
  
  def name
    "Death Bones Dan"
  end

  def new_game    
    generate_player_positions
    #generate_static_positions
  end

  def take_turn(state, ships_remaining)
    
    last_was_hit = false
    last_shot = []
    
    # check on last shot
    if @shots.length > 0
       last_shot = @shots.last
       log "last: #{last_shot.inspect}"
       last_was_hit = state[last_shot[1]][last_shot[0]] == :hit
    end
    
    if !last_was_hit
    
      shot_x = rand(10)
      shot_y = rand(10)
    
      until state[shot_y][shot_x] == :unknown
        shot_x = rand(10)
        shot_y = rand(10)    
      end
    
    else

      shot_x = rand(10)
      shot_y = rand(10)
    
      until state[shot_y][shot_x] == :unknown
        shot_x = rand(10)
        shot_y = rand(10)    
      end
      
      # last_x_u = last_shot[0] + 2
      # last_y_u = last_shot[1] + 2
      # 
      # last_x_l = last_shot[0] - 2
      # last_y_l = last_shot[1] - 2
      # 
      # shot_x = last_x_l + rand(last_x_u + 1 - last_x_l)
      # shot_y = last_x_l + rand(last_y_u + 1 - last_y_l)
      #     
      # until state[shot_y][shot_x] == :unknown
      #   shot_x = last_x_l + rand(last_x_u + 1 - last_x_l)
      #   shot_y = last_x_l + rand(last_y_u + 1 - last_y_l)
      # end
      
    end
    
    log "Shooting at #{shot_x}, #{shot_y}"
    
    @shots << [shot_x, shot_y]
    
    [shot_x, shot_y]
  end
  
end
