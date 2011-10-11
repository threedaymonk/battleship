require 'hlame/sea'
require 'hlame/gunner'

class FiringAdmiral
  def initialize()
    @sea = Sea.new
    @gunner = Gunner.new(self)
    @initial_fleet = nil
  end
  
  def update_from_radar(new_state, enemy_fleet)
    @initial_fleet = enemy_fleet if @initial_fleet.nil?
    update_sea(new_state)
    update_gunner(enemy_fleet)
  end
  
  def fire!
    self.last_shot = @gunner.fire!
  end

  attr_accessor :last_shot
  attr_accessor :last_shot_result
  attr_reader :sea
  attr_reader :initial_fleet

  def update_sea(new_state)
    unless self.last_shot.nil?
      x, y = *self.last_shot
      self.last_shot_result = new_state[y][x]
      @sea.update(x, y, last_shot_result)
    end
  end
  
  def update_gunner(enemy_fleet)
    @gunner.choose_firing_pattern(last_shot, last_shot_result, enemy_fleet)
  end

end
