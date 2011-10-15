class BishopPlayer

  def name
    "Bishop Player"
  end

  def new_game
    # not together
    ships = [Ship.new_random(2), Ship.new_random(3), Ship.new_random(3), Ship.new_random(4), Ship.new_random(5)]
    while(ships.detect { |ship| ship.next_to_any_of_these_ships?(ships) })
      ships = [Ship.new_random(2), Ship.new_random(3), Ship.new_random(3), Ship.new_random(4), Ship.new_random(5)]
    end
    
    return ships.map(&:to_standard_format)
  end


  def take_turn(raw_state, ships_remaining)
    state = State.new(raw_state)
    
    # For the first few turns, with only a look-ahead of 1 turn, the shots fired will be all in the bottom right.
    # To mix things up a bit, go random for the first few shots!
    if state.turn < 5
      shot = state.random_unknown_square
      return shot
    end
    
    
    # close off areas
    # don't bother looking in areas smaller than the smallest ship left
    # that's it
    
    # try every move and go for it if it lowers the number of areas the largest ship left can hide in.
    if state.squares_on_the_end_of_longest_hit_streak.any?    
      squares = state.squares_on_the_end_of_longest_hit_streak
    else
      squares = state.squares_in_gap_of_length(ships_remaining.sort.last)
    end
    
    raise "No squares!" if squares.empty?
    
    least_squares = state.squares_in_gap_of_length(ships_remaining.sort.last).length
    best_shots = []
    
    squares.each do |shot|
      new_raw_state = Marshal.load(Marshal.dump(raw_state)) # deep clone
      new_raw_state[shot[1]][shot[0]] = :miss
      new_state = State.new(new_raw_state)
      new_squares = new_state.squares_in_gap_of_length(ships_remaining.sort.last)

      if new_squares.length <= least_squares
        least_squares = new_squares.length
        if new_squares.length < least_squares
          best_shots << shot
        else
          best_shots = [shot]
        end
      end
    end
    
    shot = best_shots.shuffle.first    
    
    raise "Shot is nil!" if shot.nil?
    raise "Same shot again!" if state.previous_shots.include? shot
    return shot
  end
  
end


class State
  attr_reader :raw_state
  def initialize(raw_state)
    @raw_state = raw_state
  end
  
  def turn
    return @raw_state.flatten.select { |result| result != :unknown }.length
  end
  
  def random_unknown_square
    x = rand(10)
    y = rand(10)
    while @raw_state[x][y] != :unknown
      x = rand(10)
      y = rand(10)
    end
    return [y, x]
  end
  
  def previous_shots
    shots = []
    10.times do |x|
      10.times do |y|
        shots << [y, x] if @raw_state[x][y] != :unknown
      end
    end
    return shots
  end
  
  def rows
    return @raw_state
  end
  
  def columns
    columns = []
    10.times do |col_num|
      column = []
      10.times do |row_num|
        next unless @raw_state[row_num]
        column << @raw_state[row_num][col_num]
      end
      columns << column unless column.empty?
    end
    return columns
  end
  
  def squares_in_gap_of_length_in_lines(array, length, column = false)
    squares = []
    
    array.length.times do |row_num|
      row = array[row_num]
      
      first_instances = []
      10.times do |index|
        first_instances << index if (row[index] != :miss and (index == 0 or row[index - 1] == :miss))
      end
            
      first_instances.each do |first_instance|
        if !row[first_instance, length].uniq.include?(:miss) and first_instance + length <= array.length
          stop_adding = false
          col_num = first_instance
          
          row[first_instance..-1].each do |square|
            stop_adding = true if square == :miss
            next if stop_adding
            
            unless square == :hit
              if column
                squares << [row_num, col_num] 
              else
                squares << [col_num, row_num] 
              end
            end
            
            col_num += 1
          end 
        end
      end
    end
    
    return squares
  end
  
  def squares_in_gap_of_length(length)
    squares = []
    
    # Rows
    squares += squares_in_gap_of_length_in_lines(@raw_state, length)
    squares += squares_in_gap_of_length_in_lines(columns, length, column = true)
    
    return squares.uniq
  end
  
  def unknown_squares_next_to_a_hit
    4.times do |number_of_adjacent_hits|
      number_of_adjacent_hits = 4 - number_of_adjacent_hits
      squares = []
      10.times do |row|
        10.times do |column|
          result = @raw_state[row][column]
          next unless result == :unknown
          
          hits = 0
          
          hits += 1 if @raw_state[row - 1] and @raw_state[row - 1][column] == :hit
          hits += 1 if @raw_state[row + 1] and @raw_state[row + 1][column] == :hit
          hits += 1 if @raw_state[row][column - 1] == :hit
          hits += 1 if @raw_state[row][column + 1] == :hit
          
          squares << [column,row] if hits == number_of_adjacent_hits
        end
      end
      return squares if squares.any?
    end
    
    return []
  end

  def squares_on_the_end_of_longest_hit_streak
    squares = []
    @biggest_streak = 1
    
    row_squares     = squares_on_the_end_of_longest_hit_streak_for_lines(@biggest_streak, rows,     column = false)
    biggest_row_streak = @biggest_streak
    
    column_squares  = squares_on_the_end_of_longest_hit_streak_for_lines(@biggest_streak, columns,  column = true)
    biggest_column_streak = @biggest_streak
    
    if biggest_row_streak > biggest_column_streak
      return row_squares
    elsif biggest_column_streak > biggest_row_streak
      return column_squares
    else
      return row_squares + column_squares
    end
  end
        
  def squares_on_the_end_of_longest_hit_streak_for_lines(biggest_streak, lines, column = false)
    squares = []
    
    10.times do |line_index|
      line = lines[line_index]
      
      10.times do |start_point|
        10.times do |end_point|
          if line[start_point..end_point].uniq == [:hit]
            streak = end_point - start_point + 1
            if streak >= @biggest_streak
              squares = []
              @biggest_streak = streak
              
              if column
                next unless (0..9).include? line_index
                squares << [line_index, start_point - 1]        if @raw_state[start_point - 1]      and @raw_state[start_point - 1][line_index]        == :unknown and (0..9).include? start_point - 1
                squares << [line_index, start_point + streak]   if @raw_state[start_point + streak] and @raw_state[start_point + streak][line_index]   == :unknown and (0..9).include? start_point + streak
              else
                next unless (0..9).include? line_index
                squares << [start_point - 1, line_index]        if @raw_state[line_index]           and @raw_state[line_index][start_point - 1]        == :unknown and (0..9).include? start_point - 1
                squares << [start_point + streak, line_index]   if @raw_state[line_index]           and @raw_state[line_index][start_point + streak]   == :unknown and (0..9).include? start_point + streak
              end
            end
          end
        end
      end
        
    end
    
    return squares
  end

end


class Ship
  attr_accessor :x, :y, :length, :orientation
  def initialize(array)
    @x = array[0]
    @y = array[1]
    @length = array[2]
    @orientation = array[3]
  end
  
  def valid?
    return false unless (2..5).include? @length
    return false unless [:across, :down].include? @orientation
    self.squares.each do |square|
      return false unless (0..9).include? square[0]
      return false unless (0..9).include? square[1]
    end
    return true
  end
  
  def self.new_random(length)
    ship = self.new([0,0,0,:across])
    
    while !ship.valid?
      ship.x = rand(10)
      ship.y = rand(10)
      ship.length = length
      ship.orientation = [:across, :down][rand(2)]
    end
    
    return ship
  end
  
  def to_standard_format
    [@x, @y, @length, @orientation]
  end
  
  def next_to_any_of_these_ships?(other_ships)
    other_ships.each do |other_ship|
      next if self == other_ship
      return true if self.next_to_other_ship?(other_ship)
    end
    return false
  end
  
  def next_to_other_ship?(other_ship)
    raise "Comparing self with self - of course it's next to it!" if self == other_ship
    self.squares.each do |square|
      other_ship.squares.each do |other_square|
        return true if (square[0] == other_square[0] and (square[1] - other_square[1]).abs <= 1)
        return true if (square[1] == other_square[1] and (square[0] - other_square[0]).abs <= 1)
      end
    end
    return false
  end
  
  def squares
    squares = []
    case @orientation
    when :down
      @length.times do |extension|
        squares << [@x, @y + extension]
      end
    when :across
      @length.times do |extension|
        squares << [@x + extension, @y]
      end  
    end
    return squares
  end
end