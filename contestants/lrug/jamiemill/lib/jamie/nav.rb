module Jamie

  class Nav

    BOARD_SIZE = 10

    def self.around(point)
      points = []
      points << up(point)
      points << right(point)
      points << down(point)
      points << left(point)
      points.reject {|p| p.nil?}
    end

    def self.up(point,dist=1)
      crop [point[0],point[1]-dist]
    end

    def self.down(point,dist=1)
      crop [point[0],point[1]+dist]
    end

    def self.left(point,dist=1)
      crop [point[0]-dist,point[1]]
    end

    def self.right(point,dist=1)
      crop [point[0]+dist,point[1]]
    end

    def self.crop(point)
      range = 0...BOARD_SIZE
      if range.include? point[0] and range.include? point[1]
        point
      else
        nil
      end
    end

  end
end
