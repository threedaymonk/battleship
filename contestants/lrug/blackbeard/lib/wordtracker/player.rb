module Wordtracker
  class Player
    attr_accessor :history, :sweep_history, :attacking
    def initialize
      @history = []
      @sweep_history = []
      @attack_history = []
      @next_move = nil
      @board = nil
      @attacking = false
    end
    
    def set_opponent(opponent)
      @opponent = opponent
    end
    
    def assign_board(board)
      @board = board
    end
    
    def inform(state, ships_remaining)
      @opponent.board.state = state
      if @opponent.ships_remaining != ships_remaining
        last_move.sunk_ship = true
        @attack_history = []
      end
      @opponent.ships_remaining = ships_remaining
      if last_move.y > -1
        updated_last_move = Move.new(last_move.y, last_move.x, @opponent.board.get_position(last_move.y,last_move.x))
        @history[-1] = updated_last_move
        @attack_history << updated_last_move if updated_last_move.hit?
      end
    end
    
    def calculate_next_attacking_move(last_hit_or_move)
      possibles = coords_adjacent_to_move(last_hit_or_move)
      possibles.delete_if {|move| move.outcome == :miss}
      hits = possibles.select {|move| move.outcome == :hit}
      hits.each do |hit|
        difference = [last_hit_or_move.y - hit.y, last_hit_or_move.x - hit.x]
        next_move = Move.new(last_hit_or_move.y + difference[0], last_hit_or_move.x + difference[1]) # opposite the hit
        if @opponent.board.get_position(next_move.y, next_move.x) == :unknown
          return next_move
        end
      end
      possibles.delete_if {|move| move.outcome == :hit}
      return possibles[rand(possibles.length)]
    end
    
    def attack
      next_move = calculate_next_attacking_move(last_hit)
      if next_move.nil? 
        next_move = calculate_next_attacking_move(@attack_history[0])
        @attack_history = []
        if next_move.nil?
          @attacking = false
          return sweep
        end
      end
      return next_move
    end
    
    def sweep
      if @sweep_history.length < sweep_sequence.length
        next_move_in_sweep
      else
        @opponent.board.random_free_spot
      end
    end
    
    def move
      if ((last_move.hit? && !last_move.sunk_ship) ||
         (!last_move.hit? && is_attacking?))
        @attacking = true
        @next_move = attack
      else
        @attacking = false
        @next_move = sweep
      end
      take_turn
    end
    
    def is_attacking?
      @attacking
    end
    
    def last_move
      @history[-1] || Wordtracker::Move.new(-1, -1)
    end
    
    def last_hit
      return nil if @history.empty? || @history.nil?
      -1.downto(-@history.length) do |time|
        return @history[time] if @history[time].hit?
      end
      return nil
    end
    
    def history?
      !!@history.length
    end
        
    def sweep_sequence
      sequence = [
        [5,5],[4,4],[6,6],[3,3],[7,7],[2,2],[8,8],[1,1],
        [4,5],[5,4],[3,6],[6,3],[7,2],[2,7],[8,1],[1,8],
        [4,9],[0,4],[4,0],[9,4],
        [5,8],[1,5],[5,1],[8,5],
        [0.0],[9,9],[9,0],[0,9]
      ]
      sequence
    end
    
    def next_move_in_sweep
      new_move = Move.new(-1, -1, :hit)
      until new_move.outcome == :unknown
        temp_move = sweep_sequence[@sweep_history.length] || @opponent.board.random_free_spot.to_a
        new_move = Move.new(temp_move.last, temp_move.first, @opponent.board.get_position(temp_move.last, temp_move.first))
        @sweep_history << new_move
      end
      @sweep_history.delete_at(-1)
      return new_move
    rescue
      @opponent.board.random_free_spot
    end
    
    def take_turn
      @history << @next_move
      @sweep_history << @next_move unless is_attacking?
      @next_move = nil
      @history[-1]
    end
  
    def coords_adjacent_to_move(move)
      hit_coords = []
      if @attack_history.length > 1
        diffy, diffx = [@attack_history[-1].y - @attack_history[-2].y, @attack_history[-1].x - @attack_history[-2].x]
        if diffx != 0
          hit_coords << Move.new(move.y, move.x+1, @opponent.board.get_position(move.y, move.x+1)) #east
          hit_coords << Move.new(move.y, move.x-1, @opponent.board.get_position(move.y, move.x-1)) #west
        elsif diffy != 0
          hit_coords << Move.new(move.y+1, move.x, @opponent.board.get_position(move.y+1, move.x)) #south          
          hit_coords << Move.new(move.y-1, move.x, @opponent.board.get_position(move.y-1, move.x)) #north
        end
      else
        hit_coords << Move.new(move.y+1, move.x, @opponent.board.get_position(move.y+1, move.x)) #south
        hit_coords << Move.new(move.y, move.x+1, @opponent.board.get_position(move.y, move.x+1)) #east
        hit_coords << Move.new(move.y-1, move.x, @opponent.board.get_position(move.y-1, move.x)) #north 
        hit_coords << Move.new(move.y, move.x-1, @opponent.board.get_position(move.y, move.x-1)) #west
      end
      hit_coords.delete_if {|move| ! move.on_board?}
    end
  end
end