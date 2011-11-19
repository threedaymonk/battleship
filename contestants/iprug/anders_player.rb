class AndersPlayer
  def initialize
    @aim = Aim.new()
  end

  def name
    "Anders Player"
  end

  def new_game
    randy = rand(2)
    if(randy == 1)
      layout = [
        [rand(5), rand(2), 5, :across],
        [rand(6), rand(2) + 2, 4, :across],
        [rand(7), rand(2) + 4, 3, :across],
        [rand(7), rand(2) + 6, 3, :across],
        [rand(8), rand(2) + 8, 2, :across]
      ]
    else
      layout = [
        [rand(2), rand(5), 5, :down],
        [rand(2)+2, rand(6), 4, :down],
        [rand(2)+4, rand(7), 3, :down],
        [rand(2)+6, rand(7), 3, :down],
        [rand(2)+8, rand(8), 2, :down]
      ]
    end
  end

  def take_turn(state, ships_remaining)
    @aim.test(state)
  end
end

class Aim
  attr_accessor :x, :y
  
  def initialize
    @x = -1
    @x_speed = 1
    @y = 0
    @y_speed = 0
    @right_border = 9
    @left_border = 0
    @top_border = 0
    @bottom_border = 9
    
  end

  def test(state)
    if @x >= @right_border && @x_speed == 1
      @x = @right_border
      @x_speed = 0
      @y_speed = 1
      @top_border += 1
    end
    if @y >= @bottom_border && @y_speed == 1
      @y = @bottom_border
      @x_speed = -1
      @y_speed = 0
      @right_border -= 1
    end
     if @x <= @left_border && @x_speed == -1
       @x = @left_border
       @x_speed = 0
       @y_speed = -1
       @bottom_border -= 1
     end
     if @y <= @top_border && @y_speed == -1
       @y = @top_border
       @x_speed = 1
       @y_speed = 0
       @left_border += 1
     end
    
      @x += @x_speed
      @y += @y_speed
    [@x,@y]
  end
end