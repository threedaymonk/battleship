require "battleship/board"

module Battleship
  class Game
    def initialize(size, expected_fleet, *players)
      @state = build_initial_state(size, expected_fleet, players)

      @turn = 0

      @winner = @state.reverse.reject{ |player, opponent, board| board.valid? }.
                               map{ |player, opponent, board| player }.first
    end

    attr_reader :winner

    def tick
      player, opponent, board = @state[@turn]
      @turn = -(@turn - 1)

      result = board.try(player.take_turn(board.report, board.ships_remaining).dup)
      @winner = player if board.sunk?
      
      result
    end

    def names
      @state.map{ |player, _, __| player.name }
    end

    def report
      @state.map{ |_, __, board| board.report }.reverse
    end

  private
    def build_initial_state(size, expected_fleet, players)
      boards = players.map{ |player|
        positions = player.new_game
        Board.new(size, expected_fleet, positions)
      }
      players.zip(players.reverse, boards.reverse)
    end
  end
end
