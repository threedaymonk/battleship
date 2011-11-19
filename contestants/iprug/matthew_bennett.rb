def out(*args)
  puts *args
end

class Array
  def delta(arr)
    [self[0] + arr[0], self[1] + arr[1]]
  end
  
  def outside(lower, upper)
    self[0] < lower[0] || self[1] < lower[1] || self[0] > upper[0] || self[1] > upper[1]
  end
end

class UndecisivePlayer
  def name
    "@undecisive (Matthew Bennett)"
  end

  def new_game
    @previous_moves = []
    random_starting_positions
  end

  def take_turn(state, ships_remaining)
    out "Taking turn..."
    begin
      if @real_shot && hit?(@latest_attempt, state)
        out "HIT! #{@latest_attempt.inspect}"
        @surroundings = false
        @first_hit ||= @latest_attempt
        @latest_good_attempt = @latest_attempt
        @latest_attempt = try_a_surrounder
      elsif(@latest_good_attempt)
        out "Found a good shot...."
        @latest_attempt = try_a_surrounder
      else
        @latest_attempt = random_shot
      end
      @real_shot = false
      @real_shot = true unless @previous_moves.include? @latest_attempt
    end until @real_shot
    @previous_moves << @latest_attempt
    @latest_attempt
  end
  
  private
  def hit?(attempt, state)
    return false if attempt.nil?
    state[ attempt[1] ][ attempt[0] ] == :hit
  end
  
  def reset
    out "resetting..."
    @latest_attempt = nil
    @latest_good_attempt = nil
    @surroundings = []
  end
  
  def try_a_surrounder
    out "Surrounding... #{@surroundings.inspect}"
    @surroundings ||= []
    if @surroundings.length >= 4
      reset
      if(@first_hit)
        @latest_good_attempt = @first_hit
        @first_hit = nil
        #return random_shot
        return try_a_surrounder
      else
        return random_shot
      end
      return random_shot
    end

    begin
      @surroundings << @latest_good_attempt.delta(surround_addition(@surroundings.length))
    end until within_bounds?(@surroundings.last)

    @surroundings.last
  end
  
  def within_bounds?(shot)
    !shot.outside([0,0], [9,9])
  end
  
  def random_shot
    @first_hit = nil
    [rand(10), rand(10)]
  end
  
  def surround_addition(num)
    case num % 4
    when 0
      [-1,0]
    when 1
      [0,-1]
    when 2
      [1,0]
    when 3
      [0,1]
    end
  end
  
  def random_starting_positions
    [
      [0, 0, 5, :across],
      [2, 2, 4, :across],
      [4, 3, 3, :across],
      [5, 5, 3, :across],
      [8, 7, 2, :across]
    ]
  end
end
