class Convolution
  def initialize(state, kernel, &scorer)
    @state  = state
    @kernel = kernel
    @scorer = scorer
  end

  def at(x, y)
    convolve(sample(x, y), @kernel)
  end

private
  def sample(x, y)
    offset = @kernel.length / 2
    ((y - offset) .. (y + offset)).map{ |yy|
      row = @state[yy] || []
      ((x - offset) .. (x + offset)).map{ |xx|
        @scorer.call(row[xx])
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
