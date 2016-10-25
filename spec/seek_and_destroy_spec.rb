require 'spec_helper'
require_relative '../players/seek_and_destroy'


describe 'player seek and destroy' do

  let(:seek_and_destroy) { SeekAndDestroy.new }

  let(:state){
    state = []
    10.times do |row|
      column = []
      10.times do |thing|
        column << :unknown
      end
      state << column
    end
    state
  }

  let(:ships_remaining){
    [5, 4, 3, 3, 2]
  }

  it 'attacks randomly when untrained' do
    coords = []

    1000.times do
      coords << seek_and_destroy.take_turn(state, ships_remaining)
    end
    expect(coords.uniq.size).to eq 100
  end

  it "creates a snapshot file when a new game starts" do
    seek_and_destroy.new_game
    expect(File.exist?('snapshot_1.yml')).to be true
    File.delete 'snapshot_1.yml'
  end

  it "creates a new file if there is already a training file" do
    File.open("snapshot_1.yml", 'w+'){ |file| file.write("")}
    seek_and_destroy.new_game
    expect(File.exist?('snapshot_2.yml')).to be true
    File.delete 'snapshot_1.yml'
    File.delete 'snapshot_2.yml'
  end

  it 'writes state to a snapshot when it takes a turn' do
    seek_and_destroy.new_game
    seek_and_destroy.take_turn(state, ships_remaining)
    coordinates = YAML.load_file('snapshot_1.yml')
    expect(state).to eq coordinates
    File.delete 'snapshot_1.yml'
  end

end
