class RandomBombsAwayStrategy
  def initialize(board)
    @board = board
  end

  def fire
    loop do
      x = rand(@board.x_range)
      y = rand(@board.y_range)
      return [x, y] if @board.state(x, y) == :unknown
    end
  end
end


