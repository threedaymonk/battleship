# encoding: utf-8

require "stringio"
require "colored"

module Battleship
  class ConsoleRenderer
    RESET = "\e[2J\e[H"

    def render(game)
      output = StringIO.new(buffer = "")
      names  = game.names
      report = game.report
      ships  = game.ships_remaining

      output << RESET
      2.times.each do |i|
        render_player(output, names[i], report[i], ships[i])
        output.puts if i == 0
      end

      buffer
    end

  private
    ICONS = {
      :unknown => ". ",
      :hit     => "X ",
      :miss    => "~ "
    }

    def render_row(row)
      row.map{ |name| icon(name) }.join
    end

    def render_ship(length)
      return "" unless length
      "X " * length
    end

    def icon(name)
      ICONS[name]
    end

    def render_player(output, name, board, remaining)
      output.puts name, ""

      board.zip(remaining) do |row, ship|
        output << render_row(row) << "  " << render_ship(ship)
        output.puts
      end
    end
  end

  class DeluxeConsoleRenderer < ConsoleRenderer

    ICONS = {
      :unknown => "· ",
      :hit     => "█▉".red,
      :miss    => "▒▒".cyan
    }

  private
    def icon(name)
      ICONS[name]
    end

    def render_ship(length)
      return "" unless length
      "█▉" * length
    end

  end
end
