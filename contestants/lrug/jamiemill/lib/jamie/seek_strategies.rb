module Jamie
  module SeekStrategies

    class CircularSweep
      def self.points
        [
          # across, one space from top
          [1,1],[3,1],[5,1],[7,1],
          # down, one space from right
          [8,2],[8,4],[8,6],[8,8],
          # across left, one space from bottom
          [6,8],[4,8],[2,8],
          # up, one space from left
          [1,7],[1,5],[1,3],
        ]
      end
    end

    class DiagonalTLtoBR
      def self.points
        points = []
        (0..9).each do |i|
          points.push [i,i]
        end
        points
      end
    end

    class DiagonalTRtoBL
      def self.points
        points = []
        (0..9).each do |i|
          points.push [9-i,i]
        end
        points
      end
    end

    class CheckerBoard
      def self.points
        [
          [0,0],[0,2],[0,4],[0,6],[0,8],
          [1,1],[1,3],[1,5],[1,7],[1,9],
          [2,0],[2,2],[2,4],[2,6],[2,8],
          [3,1],[3,3],[3,5],[3,7],[3,9],
          [4,0],[4,2],[4,4],[4,6],[4,8],
          [5,1],[5,3],[5,5],[5,7],[5,9],
          [6,0],[6,2],[6,4],[6,6],[6,8],
          [7,1],[7,3],[7,5],[7,7],[7,9],
          [8,0],[8,2],[8,4],[8,6],[8,8],
          [9,1],[9,3],[9,5],[9,7],[9,9],
        ]
      end
    end

  end
end
