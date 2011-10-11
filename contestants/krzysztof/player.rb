class LuckyPlayer
  LAYOUTS = 
    {
   :loose_edges =>
      # loose edges
      [
        [3, 0, 5, :across],
        [0, 4, 4, :down],
        [9, 0, 3, :down],
        [9, 4, 3, :down],
        [0, 9, 2, :across]
      ],
    :tight => 
      [
        [1, 1, 5, :across],
        [1, 2, 4, :down],
        [2, 2, 3, :across],
        [3, 3, 3, :down],
        [4, 3, 2, :across]
      ],
    :tight_edges => 
      [
        [0, 0, 5, :across],
        [9, 3, 4, :down],
        [0, 1, 3, :down],
        [0, 4, 3, :down],
        [0, 8, 2, :across]
      ]
  }


  def name
    "@krist0ff"
  end

  def random_layout
    key = LAYOUTS.keys[rand(LAYOUTS.keys.size)]
    LAYOUTS[key]
  end

  def new_game
    random_layout
  end

  def take_turn(state, ships_remaining)
    setup_board(state,ships_remaining)
    @board.fire!
  end

  def setup_board state, ships_remaining
    @board = Board.new state, ships_remaining
  end

  class Board

    def initialize rows, remaining_ships
      @remaining_ships = remaining_ships
      @cells = rows.map.with_index do |row,y|
        row.map.with_index do |state,x|
          Cell.new self, :state => state, :x => x, :y => y
        end
      end
    end

    def biggest_ship_remaining
      @remaining_ships.max
    end

    def fire!
      highest_score, highest_scoring_cells = unknown_cells.group_by{|c| c.score}.sort.reverse.first
      cell = highest_scoring_cells[rand(highest_scoring_cells.size - 1)]
      cell.coords
    end

    def cell_at x,y
      return Cell::OutOfBounds.instance unless (0..9).include?(x) && (0..9).include?(y)
      @cells[y][x]
    end

    def unknown_cells
      @cells.flatten.select{|c| c.unknown?}
    end
  end

  DIRECTIONS = {:east => [:x, 1], :west => [:x, -1], :north => [:y, -1], :south => [:y, 1]}

  class Cell

    class OutOfBounds
      def self.instance
        @instance ||= OutOfBounds.new
      end

      def unknown?
        false
      end

      def out_of_bounds?
        true
      end

      def hit?
        false
      end
    end

    def inspect
      [coords,@state,score]
    end

    def initialize board, params = {}
      @board = board
      @state = params[:state]
      @x = params[:x]
      @y = params[:y]
    end

    def coords
      [@x,@y]
    end

    def score unknown_only = true
      return 0 unless unknown?
      total = DIRECTIONS.keys.inject(0) do |s, dir|
        s + score_for_direction(dir) + score_for_neighbour(dir)
      end
    end

    def unknown?
      @state == :unknown
    end

    def hit?
      @state == :hit
    end

    def score_for_neighbour dir
      n = relative_cell_at(dir)
      if n.hit?
        score_for_hit_neighbour(n, dir)
      else
        0
      end
    end

    def score_for_hit_neighbour neighbour, dir
      # if it was a hit next to this field in another axis, return 0, since
      # it's not different to any other field
      
      # if no other hit neighbours, add 20
      return 40 if neighbour.hit_neighbour_in_same_axis? dir
      return 20 if neighbour.no_hit_neighbours?
      # noone normal would place ships next to each other, that means everyone
      # will
      return 2 if neighbour.hit_neighbour_in_different_axis? dir
      return 0
      # this is ok, except when the ship at hit cell is already in
      # different direction, or when it's already complete
    end

    def no_hit_neighbours?
      DIRECTIONS.keys.all? do |dir|
        !relative_cell_at(dir).hit?
      end
    end

    def hit_neighbour_in_different_axis? dir
      if [:south, :north].include?(dir)
        [:east, :west].any? do |dir|
          relative_cell_at(dir).hit?
        end
      elsif [:east, :west].include?(dir)
        [:south, :north].any? do |dir|
          relative_cell_at(dir).hit?
        end
      end
    end

    # this is the same direction we are moving in
    def hit_neighbour_in_same_axis? dir
      relative_cell_at(dir).hit?
    end

    def relative_cell_at dir, distance = 1
      axis, sign = DIRECTIONS[dir]
      search_x = axis == :x ? @x + distance*sign : @x
      search_y = axis == :y ? @y + distance*sign : @y
      @board.cell_at(search_x, search_y)
    end

    def score_for_direction dir
      k = 1
      (@board.biggest_ship_remaining - 1).times do
        break if !relative_cell_at(dir,k).unknown?
        k = k + 1
      end
      k - 1
    end
  end
end
