require_relative "../../lib/battleship/board"

module DigitalRoninInternals

  class Evolver
    attr_accessor :placements, :scores

    def initialize(placements)
      @placements = placements
      @scores = Hash.new(0)
    end

    def mutate(placement_string)
      3.times do
        pos = rand placement_string.size
        char = placement_string[pos]
        newstr = placement_string.dup
        newstr[pos] = flip char
        placement = ShipPlacement.new newstr
        return newstr if placement.valid?
      end
      placement_string
    end

    def mortal_kombat
      placements.each {|p| evaluate p}
      winner
    end

    def evaluate(placement)
      (placements.size ** 2).times do
        result = play_game placement
        string = placement.to_s
        scores[string] += 1 if result.winner.placement.to_s == string
        scores[string] -= 1 if result.loser.placement.to_s == string
      end
    end

    private

    def flip(char)
      case char
      when 'A'
        'D'
      when 'D'
        'A'
      else
        val = char.to_i + [-1, 1][rand(2)]
        (val % 10).to_s
      end
    end

    def winner
      high_score = scores.values.max
      scores.each do |string, score|
        return ShipPlacement.new string if score == high_score
      end
    end

    def random_placement
      placements[rand(placements.size)]
    end 

    def play_game(placement)
      players = [
        DigitalRoninPlayer.new,
        DigitalRoninPlayer.new
      ]
      players[0].placement = placement
      random = random_placement
      players[1].placement = random
      # puts "%s vs. %s" % [placement, random]
      game = Battleship::Game.new(10, [2, 3, 3, 4, 5], *players)
      until game.winner
        game.tick
      end
      game
    end

  end


  class GameState
    attr_accessor :board, :cell_rankings

    # Returns a board-like array where each value in the
    # grid represents a 'rank' (high == desirable) of how
    # good an idea it would be to play the next shot into
    # that cell
    def ranked_board
      # pre-process to remove sunken ships
      string = remove_sunken_ships board_to_string
      self.board = string_to_board(string)
      set_base_rank
      increment_adjacent_to_hits
      increment_ends_of_pairs
      cell_rankings
    end

    def remove_sunken_ships(string)
      # bounded by misses
      while string =~ /(MHH+M)/ do
        len = $1.size
        string.sub!(/MHH+M/, 'M' * len)
      end

      # bounded by left edge
      while string =~ / (HH+M)/ do
        len = $1.size
        replace = ' ' << ('M' * len)
        string.sub!(/ HH+M/, replace)
      end

      # bounded by right edge
      while string =~ /(MHH+) / do
        len = $1.size
        replace = ('M' * len) << ' '
        string.sub!(/MHH+ /, replace)
      end

      # battleship has been sunk
      # string.sub! /HHHHH/, 'MMMMM'

      %w(HHHHH HHHH HHH).each do |bigship|
        if string =~ /#{bigship}/
          string.sub! /#{bigship}/, 'M' * bigship.size
        else
          break
        end
      end

      string
    end

    def string_to_board(s)
      string = s.gsub(' ', '')
      rowstring = string[0, string.size/2]
      colstring = string[string.size/2, string.size/2]
      boardsize = Math.sqrt rowstring.size

      # evaluate rows
      rows = rowstring.scan(/.{#{boardsize.to_i}}/)
      brd = rows.inject([]) do |rtn, row|
        rtn << row.split('').map {|c| char_to_sym(c)}
      end

      # column misses override row hits
      cols = colstring.scan(/.{#{boardsize.to_i}}/)
      cols.each_with_index do |col, x|
        col.split('').each_with_index do |char, y|
          brd[y][x] = char == 'M' ? :miss : brd[y][x]
        end
      end

      brd
    end

    def board_to_string
      rows = board.map {|row| arr_to_string(row)}
      cols = columns.map {|col| arr_to_string(col)}
      [rows.join(' '), cols.join(' ')].join(' ')
    end

    def columns
      cols = []
      board[0].each_with_index do |val, col|
        cols << board.map {|row| row[col]}
      end
      cols
    end

    def char_to_sym(c)
      case c
      when 'U'
        :unknown
      when 'H'
        :hit
      when 'M'
        :miss
      end
    end

    def sym_to_char(sym)
      case sym
      when :unknown
        "U"
      when :hit
        "H"
      when :miss
        "M"
      end
    end

    def arr_to_string(arr)
      arr.inject("") do |rtn, val|
        rtn << sym_to_char(val)
      end
    end

    def vertical_pairs
      self.cell_rankings ||= []   # for the tests
      pairs = []
      cells_with_hits.each do |coords|
        vertical_neighbours_of(coords).each do |neighbour|
          if cells_with_hits.include?(neighbour)
            pairs << sorted_coords(coords, neighbour)
          end
        end
      end
      pairs.uniq
    end

    def horizontal_pairs
      self.cell_rankings ||= []   # for the tests
      pairs = []
      cells_with_hits.each do |coords|
        horizontal_neighbours_of(coords).each do |neighbour|
          if cells_with_hits.include?(neighbour)
            pairs << sorted_coords(coords, neighbour)
          end
        end
      end
      pairs.uniq
    end

    private

    def sorted_coords(c1, c2)
      if c1[0] == c2[0] 
        c1[1] < c2[1] ? [c1,c2] : [c2,c1]
      else
        c1[0] < c2[0] ? [c1,c2] : [c2,c1]
      end
    end

    def increment_ends_of_pairs
      increment_ends_of_vertical_pairs
      increment_ends_of_horizontal_pairs
    end

    def increment_ends_of_vertical_pairs
      vertical_pairs.each do |pair|
        pair.each {|coords| increment_vertical_neighbours_of coords}
      end
    end

    def increment_ends_of_horizontal_pairs
      horizontal_pairs.each do |pair|
        pair.each {|coords| increment_horizontal_neighbours_of coords}
      end
    end

    def increment_vertical_neighbours_of(coords)
      vertical_neighbours_of(coords).each do |cell|
        x, y = cell
        increment_ranking x, y
      end
    end

    def increment_horizontal_neighbours_of(coords)
      horizontal_neighbours_of(coords).each do |cell|
        x, y = cell
        increment_ranking x, y
      end
    end

    def increment_neighbours(coords)
      increment_vertical_neighbours_of coords
      increment_horizontal_neighbours_of coords
    end

    def increment_adjacent_to_hits
      cells_with_hits.each {|c| increment_neighbours(c)}
    end

    def neighbours_of(coords)
      horizontal_neighbours_of(coords) + vertical_neighbours_of(coords)
    end

    def horizontal_neighbours_of(coords)
      x, y = coords
      valid_cells [[x-1,y], [x+1,y]]
    end

    def vertical_neighbours_of(coords)
      x, y = coords
      valid_cells [[x,y-1], [x,y+1]]
    end

    def valid_cells(arr)
      arr.find_all do |coords|
        x,y = coords
        valid_coord?(x) && valid_coord?(y)
      end
    end

    def valid_coord?(i)
      i >=0 && i < board.size
    end

    def cells_with_hits
      rtn = []
      each_board_cell do |x, y|
        rtn << [x,y] if cell_state(x,y) == :hit
      end
      rtn
    end

    def increment_ranking(x, y)
      cell_rankings[y][x] += 1 if cell_state(x, y) == :unknown
    end

    def increment_cells_next_to_a_hit(arr)
      arr
    end

    def set_base_rank
      self.cell_rankings = []
      each_board_cell do |x, y|
        set_rank x, y, base_rank(x,y)
      end
    end

    def set_rank(x, y, value)
      self.cell_rankings[y] ||= []
      self.cell_rankings[y][x] = value
    end

    def each_board_cell
      board.each_with_index do |row, y|
        self.cell_rankings[y] ||= []
        row.each_with_index do |col, x|
          yield x, y
        end
      end
    end

    def cell_state(x, y)
      board[y][x]
    end

    def base_rank(x, y)
      cell_state(x,y) == :unknown ? 1 : 0
    end
  end

  class ShipPlacement
    attr_accessor :string

    BOARD_SIZE = 10
    EXPECTED_FLEET = [5,4,3,3,2]

    # generate a valid random placement
    def self.random
      while true do
        string = EXPECTED_FLEET.inject("") {|string, ship_size| string << place_random(ship_size)}
        placement = new string
        return placement if placement.valid?
      end
    end

    def self.place_random(ship_size)
      [rand(BOARD_SIZE), rand(BOARD_SIZE), ship_size, ['A', 'D'][rand(2)]].join
    end

    # e.g. "005A014A023A033A042A"
    def initialize(string)
      @string = string
    end

    def render
      board = Battleship::Board.new BOARD_SIZE, EXPECTED_FLEET, self.to_a
      rtn = ""
      (0..BOARD_SIZE - 1).each do |y|
        (0..BOARD_SIZE - 1).each do |x|
          board.try([x,y]) == :hit ? rtn << 'x' : rtn << '.'
        end
        rtn << "\n"
      end
      rtn
    end

    def to_a
      ships.map {|s| to_ship(s)}
    end

    def to_s
      string
    end

    def valid?
      fleet = self.to_a
      board = Battleship::Board.new BOARD_SIZE, EXPECTED_FLEET, fleet
      board.valid?
    end

    private

    # "005A" => [0, 0, 5, :across]
    def to_ship(s)
      arr = s.split('')[0,3].map {|x| x.to_i} 
      s[3] == 'A' ? arr << :across : arr << :down
    end

    # "005A014A023A033A042A" => ["005A", "014A", "023A", "033A", "042A"] 
    def ships
      string.split(/(....)/).delete_if {|i| i == ""}
    end
  end
end

class DigitalRoninPlayer
  include DigitalRoninInternals

  attr_accessor :game_state, :placement

  # A selection of well-performing ship placements
  PLACEMENTS = %w(
    395A424D043A613A632A
    815D144D223A473A442D
    115A134A153A633A712A
    255A314D013D683A272D
    595A034D703D563A002A
    445A044A463A103D872A
    345D124D543D313A842D
    165A114D633A313A972D
    025A564D943D703D272A
  )

  def initialize
    @game_state = GameState.new
  end

  def name
    "Digital Ronin"
  end

  def new_game
    string = PLACEMENTS[rand(PLACEMENTS.size)]
    @placement ||= DigitalRoninInternals::ShipPlacement.new(string)
    @placement.to_a
  end

  def take_turn(state, ships_remaining = [])
    @ranked = nil
    game_state.board = state
    pick_cell
  end

  def ranked_board
    @ranked ||= game_state.ranked_board
  end

  def board=(arr)
    game_state.board = arr
  end

  private

  def pick_cell
    possible_moves = highest_ranked cells_with_scores
    possible_moves[rand(possible_moves.size)]
  end

  def cells_with_scores
    rtn = {}
    ranked_board.each_with_index do |row, y|
      row.each_with_index do |col, x|
        rtn[[x,y]] = row[x]
      end
    end
    rtn
  end

  # hash has keys which are cell tuples, and values 
  # which are the scores of the cells
  def highest_ranked(hash)
    max_rank = hash.values.max
    hash.keys.find_all {|cell| hash[cell] == max_rank}
  end

end



