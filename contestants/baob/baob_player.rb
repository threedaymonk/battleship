class BaobPlayer

  attr_accessor :game_state, :turns, :diagonal_offset, :last_game

  def name
    "Baob Player"
  end

  def new_game
    g = games.select{ |x| x != self.last_game }
    game = rand(g.size)
    self.last_game = g[game]
    self.last_game
  end

  def games
    [
      [
        [2, 2, 5, :across],
        [8, 4, 4, :down],
        [1, 5, 3, :down],
        [3, 8, 3, :across],
        [6, 5, 2, :down]
      ] , [
        [1, 1, 5, :across],
        [7, 4, 4, :down],
        [2, 3, 3, :down],
        [3, 7, 3, :across],
        [5, 3, 2, :down]
      ], [
        [2, 3, 5, :down],
        [4, 1, 4, :across],
        [4, 8, 3, :across],
        [8, 5, 3, :down],
        [5, 3, 2, :across]
      ] , [
        [1, 4, 5, :down],
        [4, 2, 4, :across],
        [3, 7, 3, :across],
        [7, 4, 3, :down],
        [3, 4, 2, :across]
      ]
    ]
  end

  def last_game
    @last_game ||= games[rand(games.size)]
  end

  def take_turn(state, ships_remaining)
    game_state.debug_mode = false
    game_state.update(state, ships_remaining)
    strategy = strategy_picker(game_state)
    play = strategy.execute
    game_state.last_play = play
    if game_state.debug_mode
      puts "----------- next play is #{play.inspect}"
      sleep 2
    end
    # puts turns
    self.turns += 1
    play
  end

  def initialize
    # raise RuntimeError
    @game_state = BaobPlayer::GameState.new
    @turns = 0
    @diagonal_offset = rand(10)
  end

  def print_stats(winner)
    winner_text = winner ? "won" : "lost"
    puts "I, #{self.name}, #{winner_text} in #{turns} turns"
  end

  def stats
    return turns
  end

  def strategy_picker(game_state)
    return BaobPlayer::ExpandLine.new(game_state) if game_state.unidentified_line?
    return BaobPlayer::ExpandHit.new(game_state) if game_state.unidentified_hits?
    strategy = BaobPlayer::BigSmallSquareStrategy.new(game_state)
    strategy.diagonal_offset = diagonal_offset
    strategy
  end
end

class BaobPlayer::PlayStrategy
  attr_accessor :game_state

  def initialize(game_state)
    @game_state = game_state
  end
end

class BaobPlayer::RandomStrategy < BaobPlayer::PlayStrategy

  def execute
    # game_state.debug_mode = true
    puts "-------------- entering RandomStrategy " if game_state.debug_mode
    unknown_cells = game_state.unknown_cells
    chosen = rand(unknown_cells.size)
    # puts "------ chosen ---- #{chosen.inspect} --- #{unknown_cells[chosen].inspect}"
    unknown_cells[chosen]
  end

end

class BaobPlayer::BigSmallSquareStrategy < BaobPlayer::RandomStrategy
  attr_accessor :step_size, :diagonal_offset

  def diagonal_offset
    @diagonal_offset ||= 0
  end

  def execute
    step_size = 4
    # game_state.debug_mode = true
    if step_size == 2
      unknown_cells = game_state.unknown_cells.black_squares(step_size,diagonal_offset)
    else
      unknown_cells = game_state.unknown_cells.black_squares(step_size,diagonal_offset)
      if unknown_cells.empty?
        step_size = 2
        unknown_cells = game_state.unknown_cells.black_squares(step_size,diagonal_offset)
      end
    end
    puts "-------------- entering BigSmallSquareStrategy #{step_size}" if game_state.debug_mode
    if unknown_cells.any?
      # puts "------------ true black squares strategy"
      chosen = rand(unknown_cells.size)
      # puts "------ chosen ---- #{chosen.inspect} --- #{unknown_cells[chosen].inspect}"
      unknown_cells[chosen]
    else
      super
    end
  end

end

class BaobPlayer::BlackSquareStrategy < BaobPlayer::RandomStrategy

  def execute
    puts "-------------- entering BlackSquareStrategy #{game_state.ships_remaining.min}" if game_state.debug_mode
    unknown_cells = game_state.unknown_cells.black_squares(game_state.ships_remaining.min)
    if unknown_cells.any?
      # puts "------------ true black squares strategy"
      chosen = rand(unknown_cells.size)
      # puts "------ chosen ---- #{chosen.inspect} --- #{unknown_cells[chosen].inspect}"
      unknown_cells[chosen]
    else
      super
    end
  end

end

class BaobPlayer::ExpandHit < BaobPlayer::PlayStrategy

  def execute
    # game_state.debug_mode = true
    puts "-------------- entering ExpandHit " if game_state.debug_mode
    cells = game_state.neighbours_of_unidentified
    chosen = rand(cells.size)
    # puts "------ chosen ---- #{chosen.inspect} --- #{unknown_cells[chosen].inspect}"
    cells[chosen]
  end

end

class BaobPlayer::ExpandLine < BaobPlayer::ExpandHit
  attr_reader :axis, :ref_cell

  def initialize(*args)
    super
    @axis = :x if game_state.unidentified_hits_line_in_axis?(:x)
    @axis = :y if game_state.unidentified_hits_line_in_axis?(:y)
    @ref_cell = game_state.unidentified_hits.first if @axis
  end

  def execute
    puts "-------------- entering ExpandLine " if game_state.debug_mode
    cells = game_state.neighbours_of_unidentified.inline_only(axis,ref_cell)
    if cells.any?
      chosen = rand(cells.size)
      # puts "------ chosen ---- #{chosen.inspect} --- #{unknown_cells[chosen].inspect}"
      cells[chosen]
    else
      super
    end
  end

end

class BaobPlayer::CellCollection < Array

  def black_squares(min_target=2,diagonal_offset=0)
    self.select{ |cell| (cell.first + cell.last).modulo(min_target) == diagonal_offset.modulo(min_target) }
  end

  def inline_only(axis,ref_cell)
    axis_selector = (axis == :x) ? :first : :last
    self.select{ |cell| cell.send(axis_selector) == ref_cell.send(axis_selector) }
  end

end

class BaobPlayer::GameState

  attr_accessor :state, :ships_remaining, :last_state, :last_play, :debug_mode
  attr_reader :unidentified_hits, :unidentified_sunk

  def initialize
    clear_unidentified
    known_empty 
  end

  def update(state, ships_remaining)
    @last_state = self.dup
    @state, @ships_remaining = state, ships_remaining
    find_new_hits
  end

  def unidentified_hits?
    unidentified_hits.size.nonzero?
  end

  def unidentified_hits_line_in_axis?(axis)
    return false if unidentified_hits.size == 0
    if unidentified_hits.size == 1
      return true if potential_target_in_axis?(unidentified_hits.first,axis)
      return false
    end
    return true if unidentified_hits.map(&:first).uniq.size == 1 && axis == :x
    return true if unidentified_hits.map(&:last).uniq.size == 1 && axis == :y
    return false
  end

  def unidentified_line?
    ux = unidentified_hits_line_in_axis?(:x) 
    uy = unidentified_hits_line_in_axis?(:y)
    # puts "------------------- ux #{ux}"
    # puts "------------------- uy #{uy}"
    # puts "------------------- unidentified_hits.size  #{unidentified_hits.size }"
    ux != uy
  end

  def add_unidentified_hit(hit)
    @unidentified_hits << (hit)
  end

  def add_unidentified_sunk(ship,play)
    @unidentified_sunk << {:ship => ship, :play => play }
  end

  def remove_unidentified(sunk,cells)
    @unidentified_sunk -= [sunk]
    @unidentified_hits -= cells
  end

  def total_length_unidentified_sunk
    unidentified_sunk.inject(0){ |total,sunk| total + sunk[:ship] }
  end

  def clear_unidentified
    # puts "---------- sunk identified #{@unidentified_sunk.inspect}"
    # puts "---------- hits identified #{@unidentified_hits.inspect}"
    # sleep 4
    @unidentified_sunk = []
    @unidentified_hits = []
  end


  def find_new_hits
    # self.debug_mode = true if ships_remaining.size == 1
    if last_play
      # puts "------- last play was  #{last_play.inspect} ----- result #{state[last_play.last][last_play.first] } "
      if state[last_play.last][last_play.first] == :hit
        # puts "------- !! hit found for last play #{last_play.inspect}"
        add_unidentified_hit(last_play)
      # else
      #   puts "------- no hit found for last play #{last_play.inspect} --- last last play  #{last_state.last_play.inspect}"
      #   puts "------- no new hit found in #{state.inspect}"
      end

      if state[last_play.last][last_play.first] == :miss
        add_to_known_empty(last_play)
      end
    end

    new_sunk.each { |ship| add_unidentified_sunk(ship,last_play) }
    if total_length_unidentified_sunk == unidentified_hits.size
      clear_unidentified
    end
    if unidentified_sunk.any?
      if debug_mode
        puts "---------------- we have a mess --- "
        puts "---------------- unidentified_sunk = #{unidentified_sunk.inspect}"
        puts "---------------- unidentified_hits = #{unidentified_hits.inspect}"
      end
      success = true
      (success = find_one_unidentfied_sunk) while success
      if debug_mode
        puts "================ after attempted reduction "
        puts "---------------- unidentified_sunk = #{unidentified_sunk.inspect}"
        puts "---------------- unidentified_hits = #{unidentified_hits.inspect}"
      end
    end
  end

  def find_one_unidentfied_sunk
    reduced = false
    unidentified_sunk.each do |sunk|
      possibles = hit_targets(sunk[:play],sunk[:ship])
      # puts "------------- hit_targets(#{sunk.inspect}) ------- #{possibles.inspect }"
      if possibles.size == 1
        # whoop dee doo ! one we can eliminate
        remove_unidentified(sunk,possibles.first)
        reduced = true
      end
    end
    reduced
  end

  def new_sunk
    return [] unless last_state.ships_remaining 
    return [] unless last_state.ships_remaining.size != ships_remaining.size
    # puts " ---------- comparing ships_remaining             #{ships_remaining.inspect}"
    # puts " ---------- to        last_state.ships_remaining  #{last_state.ships_remaining.inspect}"
    i = j = 0
    result = []
    while i < last_state.ships_remaining.size || j < ships_remaining.size do 
      if j >= ships_remaining.size || last_state.ships_remaining[i] != ships_remaining[j] 
        result << last_state.ships_remaining[i] 
        i += 1
      else
        i += 1 ; j += 1
      end
    end
    # puts " ---------- comparing result                      #{result.inspect}"
    # raise RuntimeError if result ==  []
    result
  end

  def unknown_cells
    result = BaobPlayer::CellCollection.new
    # puts "------ #{state.inspect}"
    (0..(state.size-1)).each do |y|
      (0..(state[y].size-1)).each do |x|
        # puts "-------- known_empty.has_key?([#{x},#{y}]) #{known_empty.has_key?([x,y])} "
        # sleep 2
        if unknown([x,y]) && potential_target?([x,y])
          result << [x,y] 
        # else
        #   puts "not worth firing on [#{x},#{y}]"
        end
      end
    end
    # puts "------ #{result.size} ---- #{result.inspect}"
    result
  end

  def known_empty
    @known_empty ||= {}
  end

  def add_to_known_empty(cell)
    # puts "------------ adding #{cell.inspect} to known_empty "
    @known_empty[cell] = cell
  end

  def potential_target?(cell)
    potential = potential_target_in_axis?(cell,:x) ||
                potential_target_in_axis?(cell,:y)
    add_to_known_empty(cell) unless potential
    potential
  end

  def hit_targets(cell,target_size=nil)
    hit_targets_in_axis(cell,:x,target_size) +
    hit_targets_in_axis(cell,:y,target_size)
  end

  def hit_targets_in_axis(cell,axis,target_size=nil)
    if axis == :x 
      direction = [1,0]
    else
      direction = [0,1]
    end
    target_size ||= ships_remaining.min
    displacement = target_size - 1
    # puts "------- entering hit_target_in_direction?(#{cell.inspect},#{direction.inspect},#{displacement}) "
    plus_count = contiguous_hit_cells(cell,direction,displacement,:+)
    minus_count = contiguous_hit_cells(cell,direction,displacement,:-)
    # puts "------- plus_count = #{plus_count} ----- minus_count = #{minus_count} "
    result = plus_count  + 1 + minus_count - displacement
    result = [0,result].max
    if result > 0
      results = (0..(result-1)).map{ |offset| contiguous_cells([cell.first + (offset-minus_count)*direction.first, cell.last + (offset-minus_count)*direction.last], direction, target_size) }
    else
      results = []
    end
    # puts "------- hit_target_in_direction?(#{cell.inspect},#{direction.inspect},#{displacement}) ----- results = #{results.inspect}"
    results
  end

  def potential_target_in_axis?(cell,axis,target_size=nil)
    if axis == :x 
      direction = [1,0]
    else
      direction = [0,1]
    end
    target_size ||= ships_remaining.min
    displacement = target_size - 1
    # puts "------- entering potential_target_in_direction?(#{cell.inspect},#{direction.inspect},#{displacement}) "
    plus_count = contiguous_target_cells(cell,direction,displacement,:+)
    minus_count = contiguous_target_cells(cell,direction,displacement,:-)
    # puts "------- plus_count = #{plus_count} ----- minus_count = #{minus_count} "
    result = plus_count + 1 + minus_count >= target_size
    # puts "------- exiting potential_target_in_direction?(#{cell.inspect},#{direction.inspect},#{displacement}) ----- result = #{result}"
    result
  end

  def contiguous_cells(cell,direction, target_size)
    displacement = target_size - 1
    # puts "----------- entering contiguous_cells(#{cell.inspect},#{direction.inspect},#{displacement} ) "
    result = []
    (0..displacement).each do |delta|
      result << [cell.first + direction.first*delta, cell.last + direction.last*delta]
    end
    # puts "----------- exiting  contiguous_cells(#{cell.inspect},#{direction.inspect},#{displacement} ) ---- result = #{result.inspect}"
    result
  end

  def contiguous_hit_cells(cell,direction,displacement,sign)
    # puts "----------- entering contiguous_hit_cells(#{cell.inspect},#{direction.inspect},#{displacement},#{sign} ) "
    good_found = true
    result = (1..displacement).select do |delta|
      check_cell = [cell.first.send(sign,direction.first*delta), cell.last.send(sign, direction.last*delta)]
      good_found = false unless unidentified(check_cell)
      good_found
    end.size
    # puts "----------- exiting  contiguous_hit_cells(#{cell.inspect},#{direction.inspect},#{displacement},#{sign} ) ---- result = #{result}"
    result
  end

  def contiguous_target_cells(cell,direction,displacement,sign)
    good_found = true
    (1..displacement).select do |delta|
      check_cell = [cell.first.send(sign,direction.first*delta), cell.last.send(sign, direction.last*delta)]
      good_found = false unless on_board_and_unknown_or_unidentified(check_cell)
      good_found
    end.size
  end

  def neighbours_of_unidentified
    result = BaobPlayer::CellCollection.new
    unidentified_hits.map do |hit|
      if potential_target_in_axis?(hit,:x)
        neighbour = [hit.first + 1, hit.last]
        result << neighbour if on_board_and_unknown(neighbour)
        neighbour = [hit.first - 1, hit.last]
        result << neighbour if on_board_and_unknown(neighbour)
      end
      if potential_target_in_axis?(hit,:y)
        neighbour = [hit.first, hit.last + 1]
        result << neighbour if on_board_and_unknown(neighbour)
        neighbour = [hit.first, hit.last - 1]
        result << neighbour if on_board_and_unknown(neighbour)
      end
    end
    result.uniq
  end

  def on_board_and_unknown(cell)
    if on_board(cell) && unknown(cell)
      # puts "-------- including  #{cell.inspect}"
      # puts "-------- state[cell.last] #{state[cell.last].inspect} "
      # puts "-------- state[cell.last][cell.first] #{state[cell.last][cell.first]}"
      return cell
    end
    return nil 
  end

  def on_board_and_unknown_or_unidentified(cell)
    if on_board(cell) && ( unknown(cell) || unidentified_hits.include?(cell) )
      # puts "-------- including  #{cell.inspect}"
      # puts "-------- state[cell.last] #{state[cell.last].inspect} "
      # puts "-------- state[cell.last][cell.first] #{state[cell.last][cell.first]}"
      return cell
    end
    return nil 
  end

  def unidentified(cell)
    if unidentified_hits.include?(cell)
      # puts "-------- including  #{cell.inspect}"
      # puts "-------- state[cell.last] #{state[cell.last].inspect} "
      # puts "-------- state[cell.last][cell.first] #{state[cell.last][cell.first]}"
      return cell
    end
    return nil 
  end

  def unknown(cell)
    if state[cell.last][cell.first] == :unknown && !known_empty.has_key?(cell)
      # puts "-------- including  #{cell.inspect}"
      # puts "-------- state[cell.last] #{state[cell.last].inspect} "
      # puts "-------- state[cell.last][cell.first] #{state[cell.last][cell.first]}"
      return cell
    end
    return nil 
  end

  def on_board(cell)
    cell.last >= 0 && cell.last <= y_max && cell.first >= 0 && cell.first <= x_max
  end

  def y_max
    state.size - 1
  end

  def x_max
    state[0].size - 1
  end

end
