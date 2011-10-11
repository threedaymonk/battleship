module Wordtracker
  class Opponent
    attr_accessor :board, :ships_remaining
    
    def initialize
      @ships_remaining = [5, 4, 3, 3, 2]
    end
    
    def assign_board(board)
      @board = board
    end
  end
end