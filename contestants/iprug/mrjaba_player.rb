class Cluster
  def initialize(on)
    @x, @y = on
  end
  
  def neighbours
    [[1,0],[0,-1],[-1,0],[0,1]].collect do |dx, dy|
      [@x + dx, @y+dy]
    end.select{ |x,y| x >= 0 && y >= 0 && x < 10 && y < 10 }
  end
end

class ClusterFire
  def initialize(cluster, shots)
    @cluster = cluster
    @shots = shots
    @queue = @cluster.neighbours.select{|shot| !@shots.include?(shot)}
  end
  
  def all
    @queue
  end
end

class RandomFire

  def next(shots)
    loop do
      tmp_shot = [rand(10), rand(10)]
      return tmp_shot if !shots.include?(tmp_shot)
    end 
  end
  
end

class PatternFire
  def initialize
    @x, @y = 9, 4
    @mode = :horizontal
    @pattern_shots = []
    @random_fire = RandomFire.new
  end
  
  def next(shots)
    if @mode == :horizontal
      @pattern_shots << [@x, @y]
      @x -= 1
      @y = @y == 4 ? 6 : 4
    end
    if @mode == :vertical
      @pattern_shots << [@x, @y]
      @y += 1
      @x = @x == 4 ? 6 : 4
    end
    if @mode == :horizontal && @x == -1
      @mode = :vertical
      @x = 4
      @y = 0
    end 
    if @mode == :fill
      @pattern_shots << [@x, @y]
      @x += 2
      if @x >= 9
        @x = @y % 2 == 0 ? 1 : 0
        @y += 1
      end 
    end
    if @mode == :vertical && @y == 9
      @mode = :fill
      @x = 0
      @y = 1
    end
    if shots.include? @pattern_shots.last
      @random_fire.next(shots)
    else
      @pattern_shots.last
    end
  end
  
end

class FiringSquad
  def initialize
    @random_fire = RandomFire.new
    @pattern_fire = PatternFire.new
    @cluster_shots = []
    @shots = []
  end
  
  def shoot(board)
    if should_pattern_fire?(board)
      @shots << @pattern_fire.next(@shots)
    elsif hit?(@shots.last, board)
      @cluster_shots += ClusterFire.new(Cluster.new(@shots.last), @shots).all
      @shots << @cluster_shots.pop
    else
      @shots << @cluster_shots.pop
    end
    if @shots.last.nil?
      @shots << @random_fire.next(@shots)
      @shots.last
    else
      @shots.last
    end
  end
  
  def should_pattern_fire?(board)
    @shots.empty? || miss?(@shots.last, board) && @cluster_shots.empty?
  end
  
  def miss?(shot, board)
    board[shot[1]][shot[0]] != :hit
  end
  
  def hit?(shot, board)
    if shot
      board[shot[1]][shot[0]] == :hit
    end
  end
  
end

class MrjabaPlayer
  
  def name
    "Mrjaba Player"
  end
  
  def initialize
    @ships = [5,4,3,3,2]
    @firing_squad = FiringSquad.new
  end
  
  def new_game
    position_ships
  end
  
  def take_turn(board, remaining_ships)
    @firing_squad.shoot(board)
  end
  
  def position_ships
    x = -1
    
    @ships.collect do |ship|
      x +=2
      top = rand(100) <= 50
      y = top ? 1 : 10 - ship
      [x, y, ship, :down]
    end    
  end
  
end

