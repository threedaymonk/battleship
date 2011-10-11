require 'custom_vector'
require 'rotator'

class UrbanautomatonPlayer
  attr_accessor :states, :moves, :ships
  attr_accessor :row_memo, :orientation, :step

  include Rotator

  UP    = Vector[-1,0]
  DOWN  = Vector[1,0]
  LEFT  = Vector[0,-1]
  RIGHT = Vector[0,1]

  def initialize
    reset
  end

  def reset
    self.moves = []
    self.ships = []
    self.states = []
    self.row_memo = Hash.new(0)
    self.orientation = rand(4)
    self.step = 4
  end

  def name
    self.class.name
  end

  def new_game
    srand
    reset
    place_ships
  end

  def take_turn(state, ships)
    srand
    update_state(state, ships)
    pos = select_move
    moves << pos
    pos.to_move
  end

  def place_ships
    orientation = rand(4)
    basic_placements.map { |p| ship_rotate(*p, orientation) }
  end

  def basic_placements
    [
      [Vector[4, 0], 5, :across],
      [Vector[6, 2], 4, :down],
      [Vector[2, 1], 3, :across],
      [Vector[4, 9], 3, :down],
      [Vector[1, 6], 2, :across],
    ]
  end

  def select_move
    kill || hunt
  end

  def random_move
    begin
      pos = Vector[rand(10), rand(10)]
    end until unknown?(pos)
    pos
  end

  # State helpers

  def state(pos)
    states.last[pos.x][pos.y]
  end

  def set_state(pos, value)
    states.last[pos.x][pos.y] = value
  end

  def state_at_pos?(state, pos)
    states.last[pos.x][pos.y] == state
  end

  [:unknown, :hit, :miss].each do |state|
    define_method(:"#{state}?") do |pos|
      pos.on_board? && state_at_pos?(state, pos)
    end
  end

  def sunk?(pos)
    states.last[pos.x][pos.y].is_a? Integer
  end

  def valid_move?(pos)
    unknown?(pos) && pos.on_board? && possible_ship?(pos)
  end

  def possible_ship?(pos)
    return true if ships.empty?
    possible_ship_down?(pos) || possible_ship_across?(pos)
  end

  def possible_ship_down?(pos)
    return true if ships.empty?
    ship_candidates_down(pos) >= ships.last.min
  end

  def possible_ship_across?(pos)
    return true if ships.empty?
    ship_candidates_across(pos) >= ships.last.min
  end

  def ship_candidate?(pos)
    unknown?(pos) || hit?(pos)
  end

  def max_ship_candidates_around(pos)
    return 0 unless ship_candidate?(pos)
    [ship_candidates_across(pos), ship_candidates_down(pos)].max
  end

  def ship_candidates_across(pos)
    return 0 unless ship_candidate?(pos)
    1 + ship_candidates_in_direction(pos + LEFT, LEFT) +
      ship_candidates_in_direction(pos + RIGHT, RIGHT)
  end

  def ship_candidates_down(pos)
    return 0 unless ship_candidate?(pos)
    1 + ship_candidates_in_direction(pos + UP, UP) +
      ship_candidates_in_direction(pos + DOWN, DOWN)
  end

  def ship_candidates_in_direction(pos, dir)
    return 0 unless ship_candidate?(pos)
    1 + ship_candidates_in_direction(pos + dir, dir)
  end

  def unique_adjacent(pos,type)
    if (adjs = adjacents(pos,type)) && adjs.length == 1
      adjs.first
    end
  end

  def adjacent_cells(pos)
    [[-1,0],[0,-1],[0,1],[1,0]].map do |c|
      pos + Vector[*c]
    end.select(&:on_board?).sort
  end

  def adjacents(pos,type)
    adjacent_cells(pos).select {|adj_pos| state_at_pos?(type, adj_pos) }
  end

  def ship_just_sunk
    if ships.length > 1
      subtract_once(ships[-2], ships[-1]).first
    end
  end

  # Updating state

  def update_state(state, new_ships)
    ships << new_ships
    if states.empty?
      states << state
    else
      states << build_state(state)
    end
    infer_sunk
  end

  def build_state(received_state)
    new_state = []
    received_state.each_with_index do |row,x|
      new_row = []
      row.each_with_index do |cell,y|
        pos = Vector[x,y]
        new_row << update_cell(pos, cell)
      end
      new_state << new_row
    end
    new_state
  end

  def update_cell(pos, cell)
    if sunk?(pos)
      state(pos)
    else
      cell
    end
  end

  def infer_sunk
    if size = ship_just_sunk
      pos = moves.last
      set_state(pos, size)
      if adj = unique_adjacent(pos,:hit)
        direction = adj - pos
        mark_in_direction(pos + direction,direction,size,size-1)
      end
    end
  end

  def mark_in_direction(pos, direction, type, num)
    if num > 0
      set_state(pos, type)
      mark_in_direction(pos + direction, direction, type, num - 1)
    end
  end

  def subtract_once(arr1, arr2)
    h = arr2.inject(Hash.new(0)) {|memo, v|
      memo[v] += 1;
      memo
    }
    arr1.reject { |e| h.include?(e) && (h[e] -= 1) >= 0 }
  end

  # KILLER

  def kill
    ship_candidates.first
  end

  def ship_candidates
    candidates = []
    states.last.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        pos = Vector[x,y]
        candidates += neighbour_candidates(pos) if hit?(pos)
      end
    end
    candidates
  end

  def neighbour_candidates(pos)
    open_line_candidates(pos) || first_hit_candidates(pos)
  end

  def first_hit_candidates(pos)
    adjs = adjacents(pos, :unknown)
    adjs.select! do |adj|
      direction = adj - pos
      if direction == UP || direction == DOWN
        possible_ship_down?(pos)
      else
        possible_ship_across?(pos)
      end
    end
    adjs.sort do |a,b|
      a_dir = a - pos
      b_dir = b - pos
      ship_candidates_in_direction(pos,b_dir) <=> ship_candidates_in_direction(pos,a_dir)
    end
  end

  def open_line_candidates(pos)
    candidates = []
    neighbour_hits = adjacents(pos, :hit)
    open_hits = neighbour_hits.select{|hit| in_open_line?(pos, hit - pos)}
    if open_hits.length > 0
      open_hits.map do |hit|
        opposite = 2 * pos - hit
        opposite if unknown?(opposite)
      end.compact
    end
  end

  def in_open_line?(pos, direction)
    opposite = Vector[0,0] - direction
    open_in_direction?(pos, direction) || open_in_direction?(pos, opposite)
  end

  def open_in_direction?(pos, direction)
    if unknown?(pos)
      true
    elsif hit?(pos)
      open_in_direction?(pos + direction, direction)
    end
  end

  # SCOURER

  def hunt
    (
      scour_move(step, 0, orientation) ||
      scour_move(step, interlace_shift, orientation) ||
      random_move
    )
  end

  def scour_move(step, shift, orientation)
    start_row = row_memo[[step,shift]]
    (start_row..10).each do |row|
      row_memo[[step,shift]] = row
      i = 0
      offset = (row + shift) % step
      begin
        col = i * step + offset
        pos = rotate(Vector[row, col], orientation)
        return pos if valid_move?(pos)
        i += 1
      end until col > 9
    end
    nil
  end

  def interlace_shift
    if ships.last
      ships.last.min
    else
      2
    end
  end

end
