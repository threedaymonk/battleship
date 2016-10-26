module GameState
  def self.write(file, state)
    File.open(file, 'w') {|f| f.write state.to_yaml }
  end
end
