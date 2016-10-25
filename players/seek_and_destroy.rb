class SeekAndDestroy
  require 'yaml'
  
  @snapshot = nil
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
    most_recent = Dir['snapshot_*.yml'].map{|str| str.gsub('snapshot_', '').to_i}.max || 0
    @snapshot = File.open("snapshot_#{most_recent + 1}.yml", 'w+')
    @snapshot.write("")
  end

  def take_turn(state, ships_remaining)
    unless @snapshot.nil?
      YAML.dump(state, @snapshot)
      @snapshot.close
    end
    [rand(10), rand(10)]
  end
end
