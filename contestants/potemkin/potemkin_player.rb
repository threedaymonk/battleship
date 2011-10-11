class PotemkinPlayer
  def initialize
    @current_sweep_x = 8
    @plane_of_attack = [[9,8],[8,9]]
    @hunt_origin = false
    @target_direction = 0
    @ships_remaining = [5,4,3,3,2]
  end
  
  def name; "Spirit of Potemkin"; end

  def new_game
    [
      [[4, 1, 5, :down],[2, 9, 4, :across],[6, 2, 3, :down],[0, 1, 3, :down],[9, 7, 2, :down]],
      [[1, 4, 5, :across],[9, 2, 4, :down],[2, 6, 3, :across],[1, 0, 3, :across],[7, 9, 2, :across]]
    ][rand(1)]
  end

  def take_turn(state, ships_remaining)
    set_state(state, ships_remaining)
    
    if @hunt_origin
      continue_the_hunt
    else
      set_move
    end
    @last_move
  end
  
  def set_move
    make_new_plane if @plane_of_attack.size == 0
    @last_move = @plane_of_attack.delete_at(rand(@plane_of_attack.size - 1))
    set_move unless untouched_square?(@last_move)
  end
    
  def set_state(state, ships_remaining)
    if @last_move
      @state[@last_move[1]][@last_move[0]] = state[@last_move[1]][@last_move[0]]
    else
      @state = state
    end
    
    if ship_killed?(ships_remaining)
      set_ship_to_hit 
      @hunt_origin = nil
    end
    set_hunt_origin
    @ships_remaining = ships_remaining.clone
  end
  
  def try_to_kill(add_or_subtract)
    @new_target = nil
    i = 1
    until i == 6
      new_move = @hunt_origin.clone
      new_move[@target_direction] += i * add_or_subtract
      if on_board?(new_move) 
        if untouched_square?(new_move)
          @new_target = new_move
          break
        else
          break if empty_square?(new_move)
        end
      end
      i += 1
    end
    @new_target
  end
  
  def continue_the_hunt
    find_target_in_current_direction
    unless @new_target
      change_direction
      find_target_in_current_direction
    end
    @last_move = @new_target
  end
  
  def set_ship_to_hit
    add_or_subtract = (@hunt_origin[@target_direction] > @last_move[@target_direction]) ? -1 : 1
    i = 0
    until i == @ship_hit
      position = @last_move.clone
      position[@target_direction] -= i * add_or_subtract
      puts 'position = ' + position.inspect
      @state[position[1]][position[0]] = :miss
      i += 1
    end
  end
  
  def find_target_in_current_direction;   try_to_kill(1) unless try_to_kill(-1); end
  def change_direction;                   @target_direction = 1 - @target_direction; end
  def untouched_square?(move);            move_status(move) == :unknown;   end
  def empty_square?(move);                move_status(move) == :miss; end
  def move_status(move);                  @state[move[1]][move[0]]; end
  def on_board?(move);                    (0..9) === move[0] and (0..9) === move[1]; end
  def set_hunt_origin;                    @hunt_origin = find_hit_position unless @hunt_origin; end
  
  def ship_killed?(ships_remaining)
    if @ships_remaining.size != ships_remaining.size
      @ship_hit = (@ships_remaining - ships_remaining)[0]
      @ship_hit = 3 if @ship_hit == nil       #OMG hacks
    end
    @ships_remaining.size != ships_remaining.size
  end
  
  def find_hit_position
    row = @state.detect{|r| r.include?(:hit)}
    row ? [row.index(:hit), @state.index(row)] : false
  end
  
  def make_new_plane
    smallest_ship = @ships_remaining.min
    @current_sweep_x -= smallest_ship
    10.times do |i|
      move = [@current_sweep_x + i, 9 - i]
      @plane_of_attack << move if on_board?(move) and untouched_square?(move)
    end
  end
end