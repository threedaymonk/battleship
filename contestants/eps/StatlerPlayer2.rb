require 'json'

class Statler2Player
  def name
    "Statler2Player"
  end

  def new_game
    positions = [
      [
        [5, 5, 5, :across],
        [5, 7, 4, :across],
        [1, 1, 3, :down],
        [3, 1, 3, :down],
        [5, 1, 2, :down]
    ],
      [
        [5, 1, 5, :across],
        [5, 3, 4, :across],
        [0, 6, 3, :down],
        [2, 6, 3, :down],
        [4, 6, 2, :down]
    ],
      [
        [5, 1, 5, :across],
        [5, 3, 4, :across],
        [1, 5, 3, :across],
        [1, 6, 3, :across],
        [1, 8, 2, :across]
    ],
      [
        [1, 1, 5, :across],
        [1, 3, 4, :across],
        [5, 5, 3, :across],
        [5, 6, 3, :across],
        [5, 8, 2, :across]
    ],
      [
        [1, 1, 5, :down],
        [3, 1, 4, :down],
        [4, 6, 3, :down],
        [6, 6, 3, :down],
        [8, 6, 2, :down]
    ],
      [
        [6, 1, 5, :down],
        [8, 1, 4, :down],
        [0, 6, 3, :down],
        [2, 6, 3, :down],
        [4, 6, 2, :down]
    ]
    ]

    #    return positions[0]
    return positions[rand(positions.size)]
  end

  def take_turn(state, ships_remaining)
    File.open("./state2", 'w') {|f| f.write(state.to_json) }
    #    [rand(10), rand(10)]
    #    rank = Array.new(10)
    #    rank.map! { Array.new(10) }

    rank = Hash.new
    (0..9).each do |i|
      (0..9).each do |j|
        rank[ [i,j] ] = 0 
      end
    end

    (0..9).each do |i|
      (0..9).each do |j|
        #        rank["#{i}|#{j}"] = 0 unless rank["#{i}|#{j}"]
        if (state[i][j] == :hit)
          #          rank[ [i,j] ] -= 1000
=begin
            if (i - 3) > -1 then rank["#{i - 3}|#{j}"] += 10 end
            if (i + 3) < 10 then rank["#{i + 3}|#{j}"] += 10 end
            if (j - 3) > -1 then rank["#{i}|#{j - 3}"] += 10 end
            if (j + 3) < 10 then rank["#{i}|#{j + 3}"] += 10 end

          close = (6 - ships_remaining.size)

          if (i - close) > -1 then rank[ [(i - close),j] ] += 10 end
          if (i + close) < 10 then rank[ [(i + close),j] ] += 10 end
          if (j - close) > -1 then rank[ [i,(j - close)] ] += 10 end
          if (j + close) < 10 then rank[ [i,(j + close)] ] += 10 end
=end

          near = 1
          if (i - near) > -1 then rank[ [(i - near),j] ] += 60 end
          if (i + near) < 10 then rank[ [(i + near),j] ] += 60 end
          if (j - near) > -1 then rank[ [i,(j - near)] ] += 60 end
          if (j + near) < 10 then rank[ [i,(j + near)] ] += 60 end


        end

        miss_neighbours i,j,state,rank
        unknown_neighbours i,j,state,rank
      end
    end

    corner = 60
    rank[ [0,0] ] += corner if state[0][0] == :unknown
    rank[ [0,9] ] += corner if state[0][9] == :unknown
    rank[ [9,0] ] += corner if state[9][0] == :unknown
    rank[ [9,9] ] += corner if state[9][9] == :unknown


    #    [1,2]
    #    rank.keys[0].split("|")

    even_squares state, rank
    line_up_hits state, rank

    rank.delete_if {|k,v| v < 0}
    File.open("./rank2", 'w') {|f| f.write(rank.to_json) }

    delete_hit_and_misses rank, state
    #    return [rand(10),rand(10)] if rank.size == 0
    sorted = rank.sort {|a,b| a[1] <=> b[1]}
    nearHits = sorted.select {|k,v| v > 40 }
    closeHits = sorted.select {|k,v| v > 0 }

    File.open("./nearhits2", 'w') {|f| f.write(sorted.to_json) }

    #    return sorted.shift[0].reverse if sorted.any?


    return nearHits[-1][0].reverse if nearHits.any?
    #    return nearHits[rand(nearHits.size)][0].reverse if nearHits.any?

    return sorted[rand(sorted.size)][0].reverse if (Time.now.to_i % 6) == 0

    #    return closeHits[rand(closeHits.size)][0].reverse if closeHits.any?

    return sorted[-1][0].reverse
    #    return sorted[rand(sorted.size)][0].reverse


    #    if sorted.last[1] > 0 then return sorted.last[0].split('|').map {|a| a.to_i } end
  end

  def line_up_hits (state, rank)
    (0..9).each do |i|
      (0..9).each do |j|
        if state[i][j] == :unknown
          if (state[i + 2, j] == :hit and state[i + 1, j] == :hit)
            rank[ [i, j] ] += 400;
          end
          if (state[i - 1, j] == :hit and state[i - 1, j] == :hit)
            rank[ [i, j] ] += 400;
          end
          if (state[i, j + 2] == :hit and state[i, j + 1] == :hit)
            rank[ [i, j] ] += 400;
          end
          if (state[i, j - 2] == :hit and state[i, j - 1] == :hit)
            rank[ [i, j] ] += 400;
          end
        end
      end
    end

  end

  def miss_neighbours (i,j,state, rank)
    if [ [i + 1, j], [i -1, j], [i, j + 1], [i,j - 1] ].select {|a| state[a[0],a[1]] == :miss }.size == 4 
      rank[ [i,j] ] -= 100 
    end
  end

  def unknown_neighbours (i,j,state, rank)
    if [ [i + 1, j], [i -1, j], [i, j + 1], [i,j - 1] ].select {|a| state[a[0],a[1]] == :unknown }.size == 4 
      rank[ [i,j] ] -= 50 
    end
  end

  def even_squares (state, rank)
    odd_or_even = 1
    (0..9).each do |i|
      (0..9).each do |j|
        if state[i][j] == :unknown
          if ( (j % 2) == 0 )            
            next if ( (i % 2) == 0)
            rank[ [i,j] ] += 50 
          end          
        end
      end
    end
  end

  def delete_hit_and_misses ( rank, state)
    (0..9).each do |i|
      (0..9).each do |j|
        if state[i][j] == :hit or state[i][j] == :miss then rank.delete([i,j]) end
      end
    end
  end

end
