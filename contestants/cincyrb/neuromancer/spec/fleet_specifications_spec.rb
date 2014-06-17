require 'rspec/given'
require 'fleet_specifications'

describe ValidShipsFleetSpecification do
  it "is not satisfied by fleets with less than 5 ships" do
    subject.should_not be_satisfied_by([[0,0,0,:down]])
  end

  it "is not satisfied by fleets with more than 5 ships" do
    fleet = [
      [0,0,1,:down],
      [0,0,1,:down],
      [0,0,1,:down],
      [0,0,1,:down],
      [0,0,1,:down],
      [0,0,1,:down],
      [0,0,1,:down],
    ]
    subject.should_not be_satisfied_by(fleet)
  end

  it "is satisfied by a fleet with the correct allotment of ships" do
    fleet = [
      [0,0,2,:down],
      [0,0,3,:down],
      [0,0,3,:down],
      [0,0,4,:down],
      [0,0,5,:down],
    ]
    subject.should be_satisfied_by(fleet)
  end
end

describe NonOverlappingFleetSpecification do
  it "is not satisfied by fleets with overlapping ships" do
    fleet = [
      [0,0,3,:across],
      [2,0,3,:down]
    ]
    subject.should_not be_satisfied_by(fleet)
  end

  it "is satisfied by fleets with no overlapping ships" do
    fleet = [
      [0,0,5,:across],
      [5,0,2,:across],
      [0,1,3,:down],
      [1,1,3,:down],
      [2,1,4,:down]
    ]
    subject.should be_satisfied_by(fleet)
  end
end

describe AllOnBoardFleetSpecification do
  subject { AllOnBoardFleetSpecification.new(BattleshipBoard.new(10)) }

  it "is not satisfied by fleets with ships off the left edge of the board" do
    subject.should_not be_satisfied_by([[-1,0,1,:down]])
  end
  it "is not satisfied by fleets with ships off the top edge of the board" do
    subject.should_not be_satisfied_by([[0,-1,1,:down]])
  end
  it "is not satisfied by fleets with ships off the right edge of the board" do
    subject.should_not be_satisfied_by([[7,7,3,:across]])
  end
  it "is not satisfied by fleets with ships off the bottom edge of the board" do
    subject.should_not be_satisfied_by([[7,7,3,:down]])
  end

  it "is satisfied by fleets with ships that are all within the confines of the board" do
    fleet = [
      [0,0,5,:across],
      [5,0,2,:across],
      [0,1,3,:down],
      [1,1,3,:down],
      [2,1,4,:down]
    ]
    subject.should be_satisfied_by(fleet)
  end
end
