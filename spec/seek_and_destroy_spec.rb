require 'spec_helper'
require_relative '../players/seek_and_destroy'

describe 'player seek and destroy' do

  let(:seek_and_destroy) { SeekAndDestroy.new }

  it 'attacks randomly when untrained' do
    coords = []
    state = []
    ships_remaining = [5, 4, 3, 3, 2]

    10.times do |row|
      column = []
      10.times do |thing|
        column << :unknown
      end
      state << column
    end

    1000.times do
      coords << SeekAndDestroy.new.take_turn(state, ships_remaining)
    end
    expect(coords.uniq.size).to eq 100
  end

end
