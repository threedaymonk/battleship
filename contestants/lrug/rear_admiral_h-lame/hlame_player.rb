require 'hlame/deployment_admiral'
require 'hlame/firing_admiral'

class HlamePlayer
  def name
    "Rear Admiral h-lame"
  end

  def new_game
    deployment_admiral.launch_fleet(5, 4, 3, 3, 2)
  end

  def take_turn(state, ships_remaining)
    firing_admiral.update_from_radar(state, ships_remaining)
    firing_admiral.fire!
  end
  
  protected
  def firing_admiral
    @firing_admiral ||= FiringAdmiral.new
  end
  
  def deployment_admiral
    @deployment_admiral ||= DeploymentAdmiral.new
  end
end
