# encoding: utf-8
class HungryWolfPlayer
  BOAT_SIZES = [5, 4, 3, 3, 2]

  def initialize
    @shots = []
  end

  def name
    'Hungry ♥ Wolf'
  end

  # [ x, y, length, orientation ]
  # 5, 4, 3, 3, 2
  def new_game
    @shots = []
    boats  = []

    BOAT_SIZES.each do |size|
      boats << place_boat(size, boats)
    end
    boats
  end

  def take_turn board, ships_remaining
    last_shot = @shots.last

    possibles = []

    if last_shot && hit?(board, *last_shot)
      possibles = surrounding(*last_shot).reject do |shot|
        @shots.include?(shot)
      end
    end

    loop do
      shot = possibles.first || [rand(10), rand(10)]
      unless @shots.include?(shot)
        @shots << shot
        return shot
      end
    end
  end

  def hit?(board, x, y)
    begin
      board[y][x] == :hit
    rescue
      false
    end
  end

  def surrounding(x, y)
    possibles = [-1, 0, 1].map { |delta_x|
      [-1, 0, 1].map { |delta_y|
        [x + delta_x, y + delta_y]
      }
    }.flatten(1) - [x, y]
    possibles.find_all { |x,y| x > 0 && y > 0 }
  end

  ###
  # size [5, 4, 3, 3, 2]
  # [[x, y, length, orientation]]
  def place_boat(size, boats)
    loop do
      guess = suggest_position(size)
      if on_map?(guess) && boats.none? { |b| overlapping?(b, guess) }
        return guess
      end
    end
  end

  def suggest_position(size)
    guess_x         = rand(10)
    guess_y         = rand(10)
    guess_orination = [:down, :across].shuffle.first
    [guess_x, guess_y, size, guess_orination]
  end

  # left: [x, y, length, orientation]
  # right: [x, y, length, orientation]
  def overlapping?(left, right)
    (tuples(left) & tuples(right)).any?
  end

  def tuples boat
    x, y, length, orientation = *boat
    if orientation == :across
      length.times.map { |i| [x + i, y] }
    else
      length.times.map { |i| [x, y + i] }
    end
  end

  # boat: [x, y, length, orientation]
  def on_map?(boat)
    x, y, length, orientation = *boat
    if orientation == :down
      y + length <= 10
    else
      x + length <= 10
    end
  end
end
