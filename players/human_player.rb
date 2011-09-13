class HumanPlayer
  def name
    "Human Player"
  end

  def new_game
    [5, 4, 3, 3, 2].map{ |length|
      puts "ship of length #{length}"
      puts "co-ordinates of top left (x,y)?"
      x, y = $stdin.gets.split(",").map{ |a| a.strip.to_i }
      puts "orientation (\"a\" for across or \"d\" for down)?"
      orientation = $stdin.gets.strip == "a" ? :across : :down
      [x, y, length, orientation]
    }
  end

  def take_turn(state, ships_remaining)
    puts "ships remaining: #{ships_remaining.inspect}"
    puts "co-ordinates (x,y)?"
    x, y = $stdin.gets.split(",").map{ |a| a.strip.to_i }
  end
end
