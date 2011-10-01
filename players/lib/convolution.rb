class Convolution
  def initialize(state, kernel)
    @state  = state
    @kernel = kernel
  end

  def at(x, y)
    convolve(sample(@state, x, y, @kernel.length), @kernel)
  end

private
  def sample(state, x, y, z)
    offset = z / 2
    ((y - offset) .. (y + offset)).map{ |yy|
      row = state[yy] || []
      ((x - offset) .. (x + offset)).map{ |xx|
        row[xx] == :hit ? 1 : 0
      }
    }
  end

  def convolve(sample, kernel)
    sample.zip(kernel).inject(0){ |sum, (srow, krow)|
      srow.zip(krow).inject(sum){ |sum, (s, k)|
        sum + s * k
      }
    }
  end
end
