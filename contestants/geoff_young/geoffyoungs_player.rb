# encoding: UTF-8

=begin

Placement Strategy

1. Dumb random placement.

Firing Strategy

1. Weight each unknown cell according to the number of permutations in which any of the remaining ships might fit in.
2. Increase the weighting of a cell if it is near a known hit[a]
3. Randomly choose from the most highly weighted cells & fire.


[a] An attempt is made each turn to identify sunk ships so that they don't affect rule 2.

=end

class GeoffYoungsPlayer
  def name
    "Geoff Youngs Player"
  end

  def new_game
    @turn = 0
    @sunk = []

    @known = GameMap.new
  
    return make_ships
  end

  class GameMap
    include Enumerable
    def initialize(map=nil)
      @map = map || Array.new(10){Array.new(10, nil)}
    end
    def each
      @map.each_with_index do |row, y|
        row.each_with_index do |val, x|
          yield(x, y, val)
        end
      end
    end
    def [](x,y)
      @map[y] && @map[y][x]
    end
    def []=(x,y,v)
      @map[y] and @map[y][x] = v
    end
    def to_s
      @map.map { |r|
        r.map { |e| 
          case e
          when Symbol, String
            e.to_s[0]
          when Numeric
            sprintf('%3i', e)
          else
            ' '
          end
        }.join(" ")
      }.join("\n")
    end
    def would_fit?(x, y, size, orientation, accept=[nil,false])
      dx, dy = orient_to_m(orientation)
      size.times do |mul|
        xp, yp = x + (dx * mul), y + (dy * mul)
  
        return false unless (xp >= 0 && xp < 10) && (yp >= 0 && yp < 10)
        return false unless accept.include?(self[xp,yp])
      end
      true
    end
    def add_ship(x, y, size, orientation)
      raise "Error!" unless would_fit?(x, y, size, orientation)
  
      dx, dy = orient_to_m(orientation)
      size.times do |mul|
        xp, yp = x + (dx * mul), y + (dy * mul)
  
        self[xp,yp] = size
      end
    end
    def orient_to_m(orientation)
      if orientation.eql? :across
        [1,0]
      else
        [0,1]
      end
    end
  end

  def make_ships
    ships = []
    @map = GameMap.new
    add_ship(ships, 5)
    add_ship(ships, 4)
    add_ship(ships, 3)
    add_ship(ships, 3)
    add_ship(ships, 2)
    ships
  end

  def add_ship(list, size)
    loop do
      orientation = rand(2) == 0 ? :down : :across
      if orientation == :down
            x, y = rand(10), rand(10-size)
      else
          x, y = rand(10 - size), rand(10)
      end
      if @map.would_fit?(x, y, size, orientation)
        @map.add_ship(x, y, size, orientation)
        list.push([x, y, size, orientation])
        return
      else
        next
      end
    end
  end

  def take_turn(state, ships_remaining)
    @turn += 1

    hits = 0

	# Copy data from state array into our @known state array
    stateMap = GameMap.new(state)
    stateMap.each do |x, y, info|
      case info
      when :hit
        hits += 1
        if [:hit, :sunk].include? @known[x, y]
          # Do nothing
        else
          @known[x, y] = info
        end
      when :miss
        @known[x, y] = info
      end
    end

	# Check to see if we sank anything during the last turn
    if @last_ships
      if @last_ships != ships_remaining
        @sunk += (@last_ships - ships_remaining)
        try_to_mark_sunk
      end
    end
    @last_ships = ships_remaining.dup

    ships_total = 5 + 4 + 3 + 3 + 2
    ships_sunk = ships_total - ships_remaining.inject(0) { |t,s| t + s }

	# Catch unidentifiable blob scenario where we know by counting that all our hits must be of sunk ships
    if ships_sunk == hits
      # Reset possibles
      @known.each { |x,y,info| @known[x,y] = :sunk if info == :hit }
    end

	# Check game map and calculate weightings
    @stats = GameMap.new
    max = 0
    likely = []
    @stats.each do |x, y, val|
      val = 0
      unless known?(x, y)
        ships_remaining.each do |size|
          [:across, :down].each do |orientation|
            size.times do |offset|
              fit = would_ship_fit_in_location?(x, y, orientation, size, offset)
              if fit
                val += 1 + (fit * fit * 5)
              end
            end
          end
        end
        if val > max
          likely = [ [x, y] ]
          max = val
        elsif val == max
          likely.push([x, y])
        end
      end
      @stats[x,y] = val
    end

    begin
      default = random_entry(likely)
    end while known?(*default)
    
    default
  end

  # Returns random entry from array
  def random_entry(arr)
    arr[rand(arr.size)]
  end

  # Returns true if we've shot at this cell in the past
  def known? x, y
    [:hit,:sunk,:miss].include? @known[x,y]
  end

  # Returns dy,dx for orientation
  def orient_to_m(orientation)
    if orientation.eql? :across
      [1,0]
    else
      [0,1]
    end
  end

  # Check to see if a ship of size
  def would_ship_fit_in_location?(x, y, orientation, size, offset=0)
    dx, dy = orient_to_m(orientation)
    known_hits = 0
    xt, yt = x - (dx * offset), y - (dy * offset)
  
    size.times do |mul|
      return false unless xt >= 0 && xt < 10
      return false unless yt >= 0 && yt < 10
      return false unless [:hit, nil, :unknown, :possible].include? @known[xt, yt]
      known_hits += (@known[xt, yt] == :hit) ? 1 : 0
      xt += dx
      yt += dy
    end
    known_hits
  end


  # Mark a ship of size as sunk starting at x,y and heading in orientation
  def mark_sunk(size, x, y, orientation)
    dx, dy = orient_to_m(orientation)
    size.times do |i|
      raise "Attempt to mark #{@known[x,y]} at #{x},#{y} as sunk part #{i} of #{size}?! (#{orientation}, #{dx}, #{dy})" unless @known[x,y] == :hit
      @known[x, y] = :sunk
      x += dx
      y += dy
    end
  end

  # Look for hits that haven't been marked sunk & attempt to identify sunk ships
  def try_to_mark_sunk
    matches = {}
    @sunk.each do |sz|
      @known.each do |x,y,v|
        next unless v == :hit
        matches[sz] ||= []
        would_ship_fit_in_location?(x, y, :across, sz, 0).eql?(sz) and
          matches[sz].push([x, y, :across])
        would_ship_fit_in_location?(x, y, :down, sz, 0).eql?(sz) and
          matches[sz].push([x, y, :down])
      end
    end

    matches.each do |sz, q|
      if q.size == @sunk.select { |s| s == sz }.size
        q.each do |entry|
          mark_sunk(sz, *entry)
        end
        @sunk -= [sz]
      end
    end
  end
end
