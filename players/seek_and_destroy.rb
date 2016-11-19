require 'yaml'
require_relative '../lib/game_state'

class SeekAndDestroy

  SNAPSHOTS_DIR = "snapshots"

  def name
    "Seek and Destroy"
  end

  def new_game
    [
      [0, 0, 5, :across],
      [0, 1, 4, :across],
      [0, 2, 3, :across],
      [0, 3, 3, :across],
      [0, 4, 2, :across]
    ]
    Dir.mkdir(SNAPSHOTS_DIR) unless Dir.exist?(SNAPSHOTS_DIR)
    most_recent_file = Dir["#{SNAPSHOTS_DIR}/*.yml"].sort.last
    if most_recent_file
      @current_file = "#{SNAPSHOTS_DIR}/#{most_recent_file.match(/\d+/)[0].to_i + 1}.yml"
      @trained = true
    else
      @current_file = "#{SNAPSHOTS_DIR}/1.yml"
      @trained = false
    end
    File.open(@current_file, 'w+'){|file| file.write("")}
  end

  def take_turn(state, ships_remaining)
    GameState.write(@current_file, state)
    if @trained
      model = Array.new(100, 0)
      Dir["#{SNAPSHOTS_DIR}/*.yml"].each do |filename|
        complete_state = GameState.load(filename).flatten
        complete_state.each_with_index do |state, index|
          if (state == :hit)
            model[index] += 1
          end
        end
      end
      return unflatten(model.each_with_index.max[1])
    else
      random_hit
    end
  end

  def unflatten(index)
    row = index/10
    column = index % 10
    [row, column]
  end

  def random_hit
    [rand(10), rand(10)]
  end
end
