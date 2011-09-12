require "battleships/board"

module Battleships
  class Game
    def initialize(size, expected_fleet, *players)
      @state = build_initial_state(size, expected_fleet, players)

      @winner = @state.reject{ |_, __, board| board.valid? }.
                       map{ |_, opponent, __| opponent }.first
    end

    attr_reader :winner

    def tick
      player, opponent, board = @state.first
      @state.reverse!

      result = board.try(player.take_turn(board.report))
      @winner = player if board.sunk?
      
      result
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
