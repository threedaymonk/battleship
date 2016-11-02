require 'spec_helper'
require 'fileutils'
require_relative '../players/seek_and_destroy'

describe 'player seek and destroy' do

  let(:seek_and_destroy) { SeekAndDestroy.new }

  after(:each) do
    FileUtils.rm_rf('snapshots')
  end

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
    seek_and_destroy.new_game
    coords = []

    1000.times do
      coords << seek_and_destroy.take_turn(state, ships_remaining)
    end
    expect(coords.uniq.size).to eq 100
  end

  it "creates a snapshot file when a new game starts" do
    seek_and_destroy.new_game
    expect(File.exist?('snapshots/1.yml')).to be true
  end

  it "creates a new file if there is already a training file" do
    Dir.mkdir("snapshots")
    File.open("snapshots/1.yml", 'w+'){ |file| file.write("")}
    seek_and_destroy.new_game
    expect(File.exist?('snapshots/2.yml')).to be true
  end

  it 'writes state to a snapshot when it takes a turn' do
    seek_and_destroy.new_game
    seek_and_destroy.take_turn(state, ships_remaining)
    coordinates = YAML.load_file('snapshots/1.yml')
    expect(state).to eq coordinates
  end

  it 'overwrites snapshot each turn' do
    seek_and_destroy.new_game
    seek_and_destroy.take_turn(state, ships_remaining)
    state[0][0] = :hit
    seek_and_destroy.take_turn(state, ships_remaining)
    coordinates = YAML.load_file('snapshots/1.yml')
    expect(state).to eq coordinates
  end

  it 'attacks most hit spot when trained' do
    old_state = state.dup
    old_state[0][0] = :hit
    GameState.write('snapshots/1.yml', old_state)
    seek_and_destroy.new_game
    coord = seek_and_destroy.take_turn(state, ships_remaining)
    expect(coord).to eq [0,0]
  end

  it 'aggregates across games to determine the most hit spot' do
    state[2][2] = :hit
    GameState.write('snapshots/1.yml', state)
    state[0][1] = :hit
    GameState.write('snapshots/2.yml', state)
    seek_and_destroy.new_game
    coord = seek_and_destroy.take_turn(state, ships_remaining)
    expect(coord).to eq [2,2]
  end

end
