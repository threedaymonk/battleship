require 'hlame/firing_pattern/hunting'
require 'hlame/firing_pattern/killing'
require 'hlame/firing_pattern/end_game'

class Gunner
  def initialize(admiral)
    @admiral = admiral
    @current_patterns = []
    @possible_patterns = [FiringPattern::EndGame, FiringPattern::Killing, FiringPattern::Hunting]
  end

  def choose_firing_pattern(last_shot, last_shot_result, enemy_fleet)
    @current_patterns = 
      initialize_patterns(last_shot, last_shot_result, enemy_fleet).map do |firing_pattern|
        if firing_pattern.wants_next_shot?(last_shot, last_shot_result, enemy_fleet) && firing_pattern.has_next_shot?
          firing_pattern
        else
          nil
        end
      end.compact
  end

  def fire!
    @current_patterns.inject(nil) {|s, fp| s = fp.next_shot! if s.nil?; s }
  end
  
  protected
  def initialize_patterns(last_shot, last_shot_result, enemy_fleet)
    @possible_patterns.map do |klazz|
      found = @current_patterns.detect {|pattern| pattern.is_a? klazz}
      if found.nil? 
        klazz.new(@admiral, last_shot, last_shot_result, enemy_fleet)
      else
        found
      end
    end.compact
  end
end