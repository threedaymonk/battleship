module Battleship
  class ConsoleRenderer
    RESET = "\e[2J"

    def initialize(output=$stdout)
      @output = output
    end

    def render(game)
      names  = game.names
      boards = game.report
      width = (names.map(&:length) + [boards.first.first.length * 2]).max
      @output.puts RESET + names[0].ljust(width) + " | " + names[1]
      @output.puts " " * width + " |"
      boards[0].zip(boards[1]).each do |a, b|
        @output.puts render_row(a).ljust(width) + " | " + render_row(b)
      end
    end

  private
    ICONS = {
      :unknown => ". ",
      :hit     => "X ",
      :miss    => "~ "
    }

    def render_row(row)
      row.map{ |x| ICONS[x] }.join
    end
  end
end
