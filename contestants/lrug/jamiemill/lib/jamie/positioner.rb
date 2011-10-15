module Jamie
  class Positioner

    def get_setup
      setups[rand(setups.size)]
    end

    def setups
      [
        # ......xx..
        # .x........
        # .x........
        # .x......x.
        # ........x.
        # ........x.
        # ........x.
        # ..xxxx..x.
        # ..........
        # .......xxx
        [
          [6, 0, 2, :across],
          [1, 1, 3, :down  ],
          [8, 3, 5, :down  ],
          [2, 7, 4, :across],
          [7, 9, 3, :across]
        ],
        # ..........
        # .xx.......
        # .xx.......
        # .xx.......
        # ..x..x....
        # ..x..x....
        # ..........
        # ..xxxx....
        # ...xxx....
        # ..........
        [
          [1, 1, 3, :down  ],
          [2, 1, 5, :down  ],
          [5, 4, 2, :down  ],
          [2, 7, 4, :across],
          [3, 8, 3, :across]
        ],
        # .....xxx..
        # .x........
        # .x........
        # .......x..
        # .......x..
        # .x.....x..
        # .x.....x..
        # .x........
        # ..xxxxx...
        # ..........
        [
          [5, 0, 3, :across],
          [1, 1, 2, :down  ],
          [7, 3, 4, :down  ],
          [1, 5, 3, :down  ],
          [2, 8, 5, :across]
        ],
      ]
    end

  end
end
