module GameState
  SNAPSHOTS_DIR = "snapshots"
  def self.write(file, state)
    Dir.mkdir(SNAPSHOTS_DIR) unless Dir.exist?(SNAPSHOTS_DIR)
    File.open(file, 'w') {|f| f.write state.to_yaml }
  end

  def self.load(file)
    YAML.load_file(file)
  end
end
