require 'rspec/given'
require 'neuromancer_player'

describe NeuromancerPlayer do
  describe "#new_game" do
    Given(:board) { BattleshipBoard.new(10) }
    Given(:player) { NeuromancerPlayer.new }
    Given(:fleet) { player.new_game }
    Then { ValidShipsFleetSpecification.new.should be_satisfied_by(fleet) }
    Then { NonOverlappingFleetSpecification.new.should be_satisfied_by(fleet) }
    Then { AllOnBoardFleetSpecification.new(board).should be_satisfied_by(fleet) }
  end
end

