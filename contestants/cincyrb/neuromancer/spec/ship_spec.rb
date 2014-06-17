require 'ship'
require 'rspec'

describe Ship do
  describe "#initialize" do
    it "can take individual args" do
      ship = Ship.new(0, 1, 3, :down)
      expect(ship.x).to eq(0)
      expect(ship.y).to eq(1)
      expect(ship.length).to eq(3)
      expect(ship.orientation).to eq(:down)
    end
    it "can take an array of args" do
      ship = Ship.new([0, 1, 3, :down])
      expect(ship.x).to eq(0)
      expect(ship.y).to eq(1)
      expect(ship.length).to eq(3)
      expect(ship.orientation).to eq(:down)
    end
  end

  describe "#coordinates" do
    it "returns (x, y) as an array" do
      expect(Ship.new(4, 2, 2, :across).coordinates).to eq([4, 2])
    end
  end

  describe "#points" do
    it "returns an array of points covered by the ship" do
      expect(Ship.new(6, 2, 3, :down).points).to eq([[6,2], [6,3], [6,4]])
    end
  end
end
