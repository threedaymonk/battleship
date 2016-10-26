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
    most_recent_file = Dir["#{SNAPSHOTS_DIR}/*.yml"].sort.last || "#{SNAPSHOTS_DIR}/0.yml"
    @current_file = "#{SNAPSHOTS_DIR}/#{most_recent_file.match(/\d+/)[0].to_i + 1}.yml"
    File.open(@current_file, 'w+'){|file| file.write("")}
  end

  def take_turn(state, ships_remaining)
    GameState.write(@current_file, state)
    [rand(10), rand(10)]
  end
end
