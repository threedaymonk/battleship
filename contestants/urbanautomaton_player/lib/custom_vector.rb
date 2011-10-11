require 'matrix'

class Vector
  include Comparable

  def <=>(v)
    to_a <=> v.to_a
  end

  def x
    self[0]
  end

  def y
    self[1]
  end

  def to_move
    to_a.reverse
  end

  def on_board?
    (0..9).cover?(x) && (0..9).cover?(y)
  end
end
