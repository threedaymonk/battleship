module BombsAwayStrategy
  class Random
    def initialize(board)
      @board = board
    end

    def fire
      loop do
        x = rand(@board.x_range)
        y = rand(@board.y_range)
        return [x, y] if @board[x, y] == :unknown
      end
    end
  end

  class ProbabilityDensity
    def initialize(board)
      @board = board
      @mode = :hunting
      @last_shot = [-1, -1]
    end

    def fire
      set_mode
      @last_shot = find_maximum_probability(calculate_probability_density)
    end

    private

    def set_mode
      case @mode
      when :hunting
        if @board[*@last_shot] == :hit
          @mode = :targeting
          @candidates = @board.neighbors(@last_shot)
          @hit_stack = [@last_shot]
        end
      when :targeting
        if sunk_ship = @board.ship_sunk?
          @mode = :hunting
          @candidates = []
          @hit_stack = []
        else
          @candidates.delete(@last_shot)
          if @board[*@last_shot] == :hit
            @candidates += @board.neighbors(@last_shot)
            @hit_stack << @last_shot
          end
        end
      end
    end

    def calculate_probability_density
      result = @board.y_range.inject([]) do |memo, row_num|
        memo << ([0] * @board.col_count)
      end

      @board.ships_remaining.each do |ship_length|
        [:across, :down].each do |orientation|
          @board.each_coordinate do |x, y|
            ship = Ship.new(x, y, ship_length, orientation)
            if @board.on_board?(ship.to_a)
              if ship.points.all? { |x, y| @board[x, y] == :unknown }
                ship.points.each do |x, y|
                  result[y][x] += 1
                end
              end
            end
          end
        end
      end

      if @mode == :targeting
        @candidates.each do |x, y|
          result[y][x] += weight(x, y)
        end
      end

      result
    end

    def find_maximum_probability(probability_density)
      max = 0
      result = nil

      probability_density.each_with_index do |row, y|
        row.each_with_index do |value, x|
          if value > max
            max = value
            result = [x, y]
          end
        end
      end

      result
    end

    def weight(x, y)
      result = if @hit_stack && @hit_stack.size > 1
        xs = @hit_stack.map { |x, y| x}.uniq
        ys = @hit_stack.map { |x, y| y}.uniq
        if xs.size == 1 && x == xs.first
          10000
        elsif ys.size == 1 && y == ys.first
          10000
        else
          500
        end
      else
        100
      end
      $stderr.puts("weight(#{x}, #{y}) with hit_stack == #{@hit_stack.inspect} => #{result}")
      result
    end

  end

end
