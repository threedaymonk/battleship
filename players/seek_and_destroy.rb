class SeekAndDestroy
  require 'yaml'

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
    @most_recent = Dir['snapshot_*.yml'].map{|str| str.gsub('snapshot_', '').to_i}.max || 0
    File.open("snapshot_#{@most_recent + 1}.yml", 'w+'){|file| file.write("")}
  end

  def take_turn(state, ships_remaining)
    File.open("snapshot_#{@most_recent + 1}.yml", 'w') {|f| f.write state.to_yaml }
    [rand(10), rand(10)]
  end
end
