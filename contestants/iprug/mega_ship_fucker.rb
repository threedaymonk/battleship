module MSF
  class Board

    NEIGHBOURS = [[0, -1], [1, 0], [0, 1], [-1, 0]]

    Point = Struct.new(:row, :column, :probability)

    def initialize
      @sunk_ships           = []
      @last_ships_remaining = [5, 4, 3, 3, 2]
      @saved_move           = nil
    end

    def update(state, ships_remaining)
      if @last_ships_remaining != ships_remaining
        @sunk_ships << ship_sunk((@last_ships_remaining - ships_remaining).first)
      end
      @state            = state
      @ships_remaining  = ships_remaining
    end

    def make_move
      squares     = free_squares
      squares     = set_probabilities(squares)
      squares     = top_probs(squares)
      #if squares.first.probability == 0
        #squares.each { |s| s.probability = ((s.row) % 2) * (s.column % 2) }
        #squares = top_probs(squares)
      #end
      @saved_move = squares[rand(squares.size)]
      [@saved_move.row, @saved_move.column]
    end

  private

    def ship_sunk(size)

    end

    def free_squares
      squares = []
      puts @state.inspect
      @state.each_with_index do |row, column_index|
        row.each_with_index do |value, row_index|
          squares << Point.new(row_index, column_index, 0) if value == :unknown
        end
      end
      squares
    end

    def set_probabilities(squares)
      squares.each do |square|
        square.probability = neighbour_hit_count(square)
      end
      squares
    end

    def neighbour_hit_count(square)
      count = 0
      NEIGHBOURS.each do |dy, dx|
        if value_at(square.row + dx, square.column + dy) == :hit
          if value_at(square.row + (dx * 2), square.column + (dy * 2)) == :hit
            count += 5
          else
            if value_at(square.row + (dx * 3), square.column + (dy * 3)) == :hit
              count += 3
            else
              count += 1
            end
          end
        end
        #count += 1 if value_at(square.row + dx, square.column + dy) == :hit
      end
      count
    end

    def top_probs(squares)
      sorted  = squares.sort { |a, b| b.probability <=> a.probability }
      top     = sorted.first
      sorted.reject { |s| s.probability < top.probability }
    end

    def value_at(row, column)
      return :unknown unless @state[column]
      @state[column][row]      
    end
  end
end

class MeggaShipFuckerPlayer

   START_BOARDS = [
      [[4, 1, 5, :down], [2, 9, 4, :across], [6, 2, 3, :down], [0, 1, 3, :down], [9, 7, 2, :down]],
      [[1, 4, 5, :across], [9, 2, 4, :down], [2, 6, 3, :across], [1, 0, 3, :across], [7, 9, 2, :across]],
      [[1, 1, 5, :down], [6, 3, 4, :across], [4, 2, 3, :down], [5, 7, 3, :across], [3, 6, 2, :down]],
    ]

  def name
    "Megga Ship Fucker - ve eatz your shipz"
  end

  def new_game
    @board = MSF::Board.new
    START_BOARDS[rand(START_BOARDS.size)]
  end

  def take_turn(state, ships_remaining)
    @board.update(state, ships_remaining)
    @board.make_move
  end
end

