require 'rspec'
require_relative '../contestants/cincyrb/justin_smith'



describe 'Ship' do
  let(:ship1) {Ship.new 1, 4, 5, :across}
  let(:ship2) {Ship.new 2, 3, 4, :down}

  describe '#each_position' do

    it 'should return an enumerable when called without a block' do
      expect(ship1.each_position).to be_an(Enumerator)
    end

    it 'should iterate over occupied positions' do
      expect { |b| ship1.each_position(&b) }.to yield_control.exactly(5).times
      expect { |b| ship1.each_position(&b) }.to yield_successive_args( [1,4], [2,4], [3,4], [4,4], [5,4])

      expect { |b| ship2.each_position(&b) }.to yield_control.exactly(4).times
      expect { |b| ship2.each_position(&b) }.to yield_successive_args( [2,3], [2,4], [2,5], [2,6])
    end
  end
end

describe 'Board' do

  describe '#add_ship' do
    let(:ship1) {Ship.new 1, 4, 5, :across}
    let(:ship2) {Ship.new 2, 3, 4, :down}

    before do
      @board1 = Board.new
    end

    it 'should return the ship' do
      @board1.add_ship(ship1).should be(ship1)
    end
  end

  describe '#occupied?' do
    let(:ship1) {Ship.new 1, 4, 5, :across}
    let(:ship2) {Ship.new 2, 3, 4, :down}

    before do
      @board1 = Board.new
    end

    it 'should mark ship positions a occupied' do
      expect(@board1).to respond_to(:add_ship)
      @board1.add_ship(ship1).should be_a(Ship)
      ship1.each_position do |x,y|
        expect(@board1.occupied?(x,y)).to be(ship1)
      end
    end

    it 'should return true when out of bounds' do
      expect(@board1.occupied?(Board.size, 0)).to be(true)
      expect(@board1.occupied?(0, Board.size)).to be(true)
      expect(@board1.occupied?(0, -1)).to be(true)
      expect(@board1.occupied?(0, -1)).to be(true)

    end
  end

  describe '#ships' do
    let(:ship1) {Ship.new 1, 4, 5, :across}

    before do
      @board1 = Board.new
    end

    it 'should return the ships added to the board' do
      @board1.add_ship(ship1).should be_a(Ship)
      expect(@board1.ships).to eq([ship1])
    end
  end
end


describe 'Ship' do
  let(:ship1) {Ship.new 1, 4, 5, :across}
  let(:ship2) {Ship.new 2, 3, 4, :down}
  let(:ship3) {Ship.new 1, 5, 4, :down}

  describe '#collision?' do
    before do
      @board1 = Board.new
      @board1.add_ship(ship1)
    end

    it 'should detect collisions' do
      expect(ship2.collision?(@board1)).to be_true
    end

    it 'should not falsely report collisions' do
      expect(ship3.collision?(@board1)).to be_false
    end
  end
end


describe 'Board' do

  before do
    @board1 = Board.new
  end

  describe '::randomly_place' do
    before do
      @lengths =  [5, 4, 3, 3, 2]
    end

    it 'should not generate any collisions' do
      @lengths.each do |length|
        Ship.randomly_place(length, @board1)
      end

      count = 0
      (0...Board.size).each do |x|
        (0...Board.size).each do |y|
          count += 1 if @board1.occupied?(x,y)
        end
      end
      expect(count).to eq(@lengths.inject(:+))
    end
  end
end

describe 'JustinSmithPlayer' do
  before do
    @player = JustinSmithPlayer.new
  end

  describe '#new_game' do
    let(:ships) { @player.new_game.map{|x| Ship.new *x } }

    it 'should return 5 ships' do
      expect(ships).to have_exactly(5).items
    end

    it 'should not allow collisions' do
      board = Board.new
      board.add_ship ships[0]
      ships[1...ships.length].each do |ship|
        expect(ship.collision? board).to be_false
        board.add_ship ship
      end
    end

  end
end

describe 'Pos' do
  before do
    @state = []
    Board.size.times do
      @state << [:unknown] * Board.size
    end
  end

  describe '#value' do

    it 'should value squares away from the edges' do
      expect(Pos.new(1, 1, @state, [5]).value).to be > Pos.new(0, 0, @state, [5]).value
      expect(Pos.new(2, 2, @state, [5]).value).to be > Pos.new(1, 1, @state, [5]).value
      expect(Pos.new(3, 3, @state, [5]).value).to be > Pos.new(2, 2, @state, [5]).value
      expect(Pos.new(4, 4, @state, [5]).value).to be > Pos.new(3, 3, @state, [5]).value
    end

    it 'should highly value squares neighboring hits' do
      @state[1][1] = :hit
      #puts @state.inspect
      expect(Pos.new(4, 1, @state, [5]).value).to be >= Pos.new(4, 4, @state, [5]).value
      expect(Pos.new(4, 4, @state, [5]).value).to be > Pos.new(0, 0, @state, [5]).value
    end
  end
end

describe 'JustinSmithPlayer' do
  before do

  end

  describe '#take_turn' do
  end
end
