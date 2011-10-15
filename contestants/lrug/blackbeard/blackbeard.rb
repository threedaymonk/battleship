require 'wordtracker/board'
require 'wordtracker/fleet'
require 'wordtracker/move'
require 'wordtracker/opponent'
require 'wordtracker/our_board'
require 'wordtracker/player'
require 'wordtracker/ship'

class BlackbeardPlayer
  def name
    "Captain Blackbeard - he's a captain and he has a beard."
  end

  def new_game
    @b = Wordtracker::OurBoard.new(10, 10)
    f = Wordtracker::Fleet.new([5,4,3,3,2])
    p = Wordtracker::Player.new
    o = Wordtracker::Opponent.new
    o.assign_board(Wordtracker::Board.new(10, 10))
    p.set_opponent(o)
    
    @b.assign_fleet(f)
    @b.assign_player(p)
    until @b.valid?
      f.ships.each do |ship|
        ship.place(@b)
      end
    end
    return f.to_a
  end

  def take_turn(state, ships_remaining)
    @b.player.inform(state, ships_remaining)
    @b.player.move.to_a
  end
end
