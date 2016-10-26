require 'game_state'

describe 'game state' do

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

  it 'can be written' do
    GameState.write('some_file.yml', state)
  end
end
