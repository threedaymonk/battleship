require 'set'

class GuntherPlayer
  def name
    "Gunther"
  end

  def new_game
    combo = ShipsFactory.random_non_overlapping
    combo.ships.map {|s| s.to_a}
  end

  def take_turn(state, ships_remaining)
    board = Board.new_from_state(state)
    Engines::Filler2.new.tick(board, ships_remaining)
  end
end

class Array
  def random_element
    self[rand(self.size)]
  end

  def sum
    inject { |a, b| a + b }
  end

  def mean
    sum.to_f / size.to_f
  end
end

class Board
  attr_accessor :hits, :misses

  def self.new_from_state(state)
    hits = []
    misses = []
    state.each_with_index do |row, y|
      row.each_with_index do |status, x|
        case status
        when :hit;  hits << [x, y]
        when :miss; misses << [x, y]
        end
      end
    end
    new(:hits => hits, :misses => misses)
  end

  def initialize(opts={})
    hit_points  = opts[:hits]   || []
    miss_points = opts[:misses] || []
    @hits = ImmutableGrid.new(hit_points)
    @misses = ImmutableGrid.new(miss_points)
  end

  def to_s
    s = 0.upto(9).map do |y|
      0.upto(9).map do |x|
        case
        when @hits.present?(x, y); 'H'
        when @misses.present?(x, y); 'm'
        else; '.'
        end
      end.join(' ')
    end.join("\n")
    "\n#{s}"
  end

  def to_a
    0.upto(9).map do |y|
      0.upto(9).map do |x|
        case
        when @hits.present?(x, y); :hit
        when @misses.present?(x, y); :miss
        else; :unknown
        end
      end
    end
  end

  def count
    @hits.size + @misses.size
  end

  def empty?
    count == 0
  end

  def set_hit(x, y)
    Board.new(:hits   => @hits.points + [[x, y]],
              :misses => @misses.points)
  end

  def set_miss(x, y)
    Board.new(:hits   => @hits.points,
              :misses => @misses.points + [[x, y]])
  end
end


class BoardFiller
  attr_accessor :board, :partial_combo

  DEFAULT_TIME_LIMIT = 5
  DEFAULT_PER_ITERATION_TIME_LiMIT = 0.05

  def initialize(board, partial_combo, opts = {})
    @board                    = board
    @partial_combo            = partial_combo
    @sizes_remaining          = partial_combo.sizes_remaining
    @time_limit               = opts[:time_limit] || DEFAULT_TIME_LIMIT
    @per_iteration_time_limit = opts[:per_iteration_time_limit] || DEFAULT_PER_ITERATION_TIME_LiMIT
  end

  def random_set(n)
    set = []
    t1 = Time.now
    n.times do |i|
      set << random
      if i % (n / 10 + 1) == 0
        return set if Time.now - t1 > @time_limit
      end
    end
    set
  end

  def random
    combo = Ships.new(*@partial_combo.ships)
    i = 0
    t1 = Time.now
    @sizes_remaining.each_with_index do |size, i1|
      while(true)
        i += 1
        ship = ShipFactory.random(size)
        if i % 1000 == 0
          return combo if Time.now - t1 > @per_iteration_time_limit
        end
        if ship_fits?(ship, combo)
          combo << ship
          break
        end
      end
    end
    combo
  end

  def ship_fits?(ship, combo)
    return false unless ship_avoids_misses?(ship, @board)

    ships = [ship] + combo.ships
    !Ships.overlap?(*ships)
  end

  def ship_avoids_misses?(ship, board)
    !Ships.overlap?(ship, board.misses)
  end
end

class Grid
  attr_reader :set

  def initialize(input = nil)
    @set = Set.new
    case input
    when Set
      @set = input
    when Array
      input.each do |x, y|
        _put(x, y)
      end
    end
  end

  def put(x, y)
    _put(x, y)
  end

  def to_s
    s = 0.upto(9).map do |y|
      0.upto(9).map do |x|
        present?(x, y) ? 'X' : '.'
      end.join(' ')
    end.join("\n")
    "\n#{s}"
  end

  def present?(x, y)
    @set.include? number(x, y)
  end

  def inspect
    to_s
  end

  def mask
    mask = 0
    @set.each do |n|
      mask += 2**n
    end
    mask
  end

  def to_a
    @set.to_a
  end

  def size
    @set.size
  end

  def &(grid)
    @set & grid.set
  end

  def |(grid)
    @set | grid.set
  end

  def subset?(grid)
    @set.subset?(grid.set)
  end

  def number(x, y)
    y + (x * 10)
  end

  def points
    @set.map { |n| Grid.coords(n) }
  end

  def min_point
    Grid.coords @set.min
  end

  def self.coords(n)
    x = (n - (n % 10)) / 10
    y = n % 10
    [x, y]
  end

  protected

  def _put(x, y)
    @set << number(x, y)
  end
end

class ImmutableGrid < Grid

  def put(x, y)
    nil
  end

  def mask
    @_mask ||= super
  end

  def generate_matrix
    m = Matrix.zeros[10]
    points.each do |x, y|
      m[x, y]
    end
  end
end

class Matrix
  attr_accessor :a

  def initialize(a = nil)
    if a && a.size == 100
      @a = a
    else
      @a = Array.new(100, 0)
    end
  end

  def <<(grid)
    grid.set.each do |n|
      @a[n] += 1
    end
  end

  def +(matrix)
    total_a = []
    @a.each_with_index {|n, i| total_a[i] = n + matrix.a[i]}
    Matrix.new(total_a)
  end

  def max
    @a.max
  end

  def to_s
    digits = max.to_i.to_s.length + 1
    s = 0.upto(9).map do |y|
      0.upto(9).map do |x|
        "%-#{digits}.1f" % self[x, y].to_s
      end.join(' ')
    end.join("\n")
    "\n#{s}"
  end

  def to_a
    @a
  end

  def erase(grid)
    grid.set.each do |n|
      @a[n] = 0
    end
  end

  def [](x, y)
    i = Matrix.point_to_index(x, y)
    @a[i]
  end

  def []=(x, y, n)
    i = Matrix.point_to_index(x, y)
    @a[i] = n
  end

  def max_point
    max_index = @a.each_with_index.max[1]
    Matrix.index_to_point(max_index)
  end

  def self.index_to_point(i)
    x = (i - (i % 10)) / 10
    y = i % 10
    [x, y]
  end

  def self.point_to_index(x, y)
    y + x * 10
  end
end

class Ship < ImmutableGrid
  def self.build(x, y, size, orientation)
    dx, dy = (orientation == :across) ? [1, 0] : [0, 1]
    coords = (0...size).map do |i|
      [x + dx * i, y + dy * i]
    end
    new(coords)
  end

  def empty?
    @set.empty?
  end

  def overlaps_with_a_hit?(board)
    !(board.hits & self).empty?
  end

  def avoids_misses?(board)
    (board.misses & self).empty?
  end

  def sunk?(board)
    self.set.subset?(board.hits.set)
  end

  def orientation
    x_points = points.map {|x, y| x }
    x_points.uniq.size == 1 ? :down : :across
  end

  def to_a
    x, y = min_point
    [x, y, size, orientation]
  end
end

class ShipFactory
  @@_sets = {}

  class << self
    def random(ship_size)
      set(ship_size).random_element
    end

    def set(ship_size)
      @@_sets[ship_size] ||= build_set(ship_size)
    end

    def partial_set(board, ship_size)
      set(ship_size).select {|ship| ship.overlaps_with_a_hit?(board) && ship.avoids_misses?(board) } + [Ship.new]
    end

    def partial_set2(board, ship_size, is_remaining)
      sunk = !is_remaining
      set = partial_set(board, ship_size)
      if sunk
        set.select {|s| s.sunk?(board) && !s.empty? }
      else
        set.select {|s| !s.sunk?(board) || s.empty? }
      end
    end

    def build_set(ship_size)
      set = []
      0.upto(9) do |y|
        0.upto(10-ship_size) do |x|
          set << Ship.build(x, y, ship_size, :across)
          set << Ship.build(y, x, ship_size, :down)
        end
      end
      set.sort { rand }
    end

    def full_group
      [2, 3, 3, 4, 5].map do |size|
        set(size)
      end
    end
  end
end

class Ships
  attr_reader :ships, :grid

  def initialize(*ships)
    @ships  = *ships.select {|ship| !ship.empty?}
    refresh
  end

  def refresh
    big_set = @ships.map { |s| s.set }.inject { |s1, s2| s1 + s2 }
    @grid  = ImmutableGrid.new(big_set)
  end

  def count
    @ships.size
  end

  def size
    @_size ||= @ships.map {|s| s.size}.sum
  end

  def sizes
    @sizes ||= @ships.map { |s| s.size }
  end

  def mask
    @grid.mask
  end

  def overlap?
    size > @grid.size
  end

  def to_s
    @grid.to_s
  end

  def <<(ship)
    @ships << ship unless ship.empty?
    refresh
  end

  def avoid_misses?(board)
    (board.misses & @grid).empty?
  end

  def cover_all_hits?(board)
    board.hits.subset?(@grid)
  end

  def self.overlap?(*ships)
    overlap_mask_impl?(*ships)
  end

  def self.overlap_set_impl?(*ships)
    new(*ships).overlap?
  end

  def self.overlap_mask_impl?(*grids)
    a, b, c, d, e, f = grids.map {|g| g.mask}
    case grids.size
    when 1; false
    when 2; a + b                 != a | b
    when 3; a + b + c             != a | b | c
    when 4; a + b + c + d         != a | b | c | d
    when 5; a + b + c + d + e     != a | b | c | d | e
    when 6; a + b + c + d + e + f != a | b | c | d | e | f
    end
  end

  def remaining(board)
    ships.map do |ship|
      ship.sunk?(board) ? nil : ship.size
    end.compact
  end

  def ship_at?(x, y)
    @grid.present?(x, y)
  end

  def sizes_remaining
    h = {2 => 1,
         3 => 2,
         4 => 1,
         5 => 1}
    sizes.each {|size| h[size] -= 1}
    remaining = []
    h.each {|k, v| v.times { remaining << k } }
    remaining
  end
end

class ShipsFactory

  class << self
    def random
      ships = []
      [2, 3, 3, 4, 5].each do |ship_size|
        ships << ShipFactory.set(ship_size).random_element
      end
      Ships.new(*ships)
    end

    def random_non_overlapping
      while(true)
        ships = random
        return ships unless ships.overlap?
      end
    end

    def partial_combos(board, ships_remaining)
      ssa = ShipFactory.partial_set2(board, 5, ships_remaining.include?(5))
      ssb = ShipFactory.partial_set2(board, 4, ships_remaining.include?(4))
      ssc = ShipFactory.partial_set2(board, 3, ships_remaining.include?(3))
      ssd = ShipFactory.partial_set2(board, 3, ships_remaining.count {|s| s == 3} > 1)
      sse = ShipFactory.partial_set2(board, 2, ships_remaining.include?(2))

      combos = []
      ssa.each_with_index do |a, i1|
        ssb.each do |b|
          next if Ships.overlap?(a, b)
          ssc.each do |c|
            next if Ships.overlap?(a, b, c)
            ssd.each do |d|
              next if Ships.overlap?(a, b, c, d)
              sse.each do |e|
                next if Ships.overlap?(a, b, c, d, e)
                ships = Ships.new(a, b, c, d, e)
                combos << ships if ships.cover_all_hits?(board)
              end
            end
          end
        end
      end
      combos
    end
  end
end

module Engines
  class Engine
    def initialize
      @debug = {}
    end

    def debug_string
      lines = []
      @debug.each do |k, v|
        lines << "#{k}: #{v}"
      end
      lines.join("\n")
    end
  end
end

module Engines
  class Filler2 < Engine

    PERMS = 2000

    def tick(board, ships_remaining)
      @board = board
      @partial_combos = ShipsFactory.partial_combos(board, ships_remaining)
      @full_combos    = full_combos

      matrix(@full_combos).max_point
    end

    def matrix(combos)
      m = Matrix.new
      combos.each {|c| m << c.grid }
      m.erase(@board.hits)
      m.erase(@board.misses)
      m
    end

    def full_combos
      combos = []
      @partial_combos.each do |combo|
        bf = BoardFiller.new(@board, combo, :time_limit => 8.0 / @partial_combos.size.to_f)
        full_sets = bf.random_set(fill_ratio)
        full_sets.each { |combo| combos << combo }
      end
      combos
    end

    def fill_ratio
      r = (PERMS / @partial_combos.size).to_i
      r < 1 ? 1 : r
    end
  end
end