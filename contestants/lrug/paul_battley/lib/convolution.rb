class Convolution
  def initialize(state, kernel, &scorer)
    @state       = state
    @flat_kernel = kernel.flatten
    @scorer      = scorer
    @offset      = kernel.length / 2
  end

  def at(x, y)
    convolve(flat_sample(x, y), @flat_kernel)
  end

private
  def flat_sample(x, y)
    ((y - @offset) .. (y + @offset)).map{ |yy|
      row = @state[yy] || []
      ((x - @offset) .. (x + @offset)).map{ |xx|
        @scorer.call(row[xx])
      }
    }.flatten
  end

  def convolve(flat_sample, flat_kernel)
    flat_sample.zip(flat_kernel).inject(0){ |sum, (s, k)|
      sum + s * k
    }
  end
end
