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

  after(:each) do
    FileUtils.rm_rf('snapshots')
  end

  it 'can be written' do
    GameState.write('snapshots/some_file.yml', state)
    File.exist?('snapshots/some_file.yml')
  end

  it 'can be saved and loaded' do 
    GameState.write('snapshots/some_file.yml', state)
    new_state = GameState.load('snapshots/some_file.yml')
    expect(state).to eq(new_state)
  end
end
