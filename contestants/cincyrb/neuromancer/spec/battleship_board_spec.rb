require 'battleship_board'

describe BattleshipBoard do
  describe "#[]" do
    it "is initially :unknown" do
      expect(subject[1,1]).to eq(:unknown)
    end

    it "is nil for points not on the board" do
      expect(subject[99,99]).to be_nil
    end
  end

  describe "#on_board?" do
    context "point arguments" do
      it "works with two arguments representing a point" do
        expect(subject.on_board?(0, 0)).to be_true
      end
      it "works with a two element array representing a point" do
        expect(subject.on_board?([0, 0])).to be_true
      end

      it "is false for points not on the board" do
        expect(subject.on_board?(-1, 1)).to be_false
        expect(subject.on_board?(1, -1)).to be_false
        expect(subject.on_board?(99, 1)).to be_false
        expect(subject.on_board?(1, 99)).to be_false
      end
    end

    context "ship arguments" do
      it "works with four arguments representing a ship" do
        expect(subject.on_board?(1, 1, 4, :across)).to be_true
      end
      it "works with a four element array representing a ship" do
        expect(subject.on_board?([1, 1, 4, :across])).to be_true
      end
    end
  end

  describe "#neighbors" do
    it "returns neighboring points on board" do
      neighbors = subject.neighbors(4, 4)
      expect(neighbors).to eq([[4, 3], [5, 4], [4, 5], [3, 4]])
    end
  end

  describe "#ship_sunk?" do
    it "is nil when no ship was sunk last round" do
      subject.update!([], [2,3,3,4,5])
      expect(subject.ship_sunk?).to be_nil
    end

    it "is the length of the ship sunk on the last round" do
      subject.update!([], [2,3,3,4,5])
      subject.update!([], [2,3,4,5])
      expect(subject.ship_sunk?).to eq(3)
    end
  end
end
