require 'custom_vector'

module Rotator

  ROTATIONS = [
    Matrix[[ 1,  0],
           [ 0,  1]],
    Matrix[[ 0, -1],
           [ 1,  0]],
    Matrix[[-1,  0],
           [ 0, -1]],
    Matrix[[ 0,  1],
           [-1,  0]],
  ]

  TRANSLATIONS = [
    Vector[0, 0],
    Vector[1, 0],
    Vector[1, 1],
    Vector[0, 1],
  ]

  DIRECTION_NEXT = {
    :across => :up,
    :up     => :left,
    :left   => :down,
    :down   => :across,
  }

  DIRECTION_ADJUST = {
    :across => [Vector[ 0,  0], :across],
    :up     => [Vector[-1,  0], :down],
    :left   => [Vector[ 0, -1], :across],
    :down   => [Vector[ 0,  0], :down],
  }

  def rotate(pos, orientation)
    (ROTATIONS[orientation] * pos) + (TRANSLATIONS[orientation] * 10)
  end

  def ship_rotate(pos, length, direction, orientation)
    rotated_pos = rotate(pos, orientation)
    new_direction = direction_rotate(direction, orientation)
    convert_to_placement(rotated_pos, length, new_direction)
  end

  def direction_rotate(direction, orientation)
    orientation.times do
      direction = DIRECTION_NEXT[direction]
    end
    direction
  end

  def convert_to_placement(pos, length, direction)
    (adj_vec, new_dir) = DIRECTION_ADJUST[direction]
    new_pos = pos + (adj_vec * length)
    [new_pos.y, new_pos.x, length, new_dir]
  end

end
