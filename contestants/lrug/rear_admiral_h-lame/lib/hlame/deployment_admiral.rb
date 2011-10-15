require 'hlame/sea'

class DeploymentAdmiral
  def initialize
    @sea = Sea.new
  end

  def launch_fleet(*fleet)
    fleet.map do |ship|
      launch_ship(ship)
    end
  end

  def launch_ship(ship)
    attempt = generate_ship_position(ship)

    if @sea.collision?(attempt)
      launch_ship(ship)
    else
      @sea.deploy(attempt)
      attempt
    end
  end
  
  protected
  
  def generate_ship_position(ship)
    orientation = rand > 0.5 ? :across : :down

    x_lim = @sea.x_size
    x_lim = x_lim - ship if orientation == :across
    x = rand(x_lim)

    y_lim = @sea.y_size
    y_lim = y_lim - ship if orientation == :down
    y = rand(y_lim)

    [x, y, ship, orientation]
  end

end
