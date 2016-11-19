class Model
SNAPSHOTS_DIR = "snapshots"

  def self.setup_training
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

  def self.update_model(state)
    GameState.write(@current_file, state)
  end

  def self.model_trained
    @trained
  end

  def self.build_model
    model = Array.new(100, 0)
    Dir["#{SNAPSHOTS_DIR}/*.yml"].each do |filename|
      complete_state = GameState.load(filename).flatten
      complete_state.each_with_index do |state, index|
        if (state == :hit)
          model[index] += 1
        end
      end
    end
    model
  end

end
