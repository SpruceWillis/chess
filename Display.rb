require "Colorize"
require_relative "cursorable"
##Thanks to rglassett on github for this code!
class Display
  attr_accessor :message
  include Cursorable


  def initialize(board)
    @board = board
    @cursor_pos = [0, 0]
    @message = nil
  end

  def build_grid
    @board.rows.map.with_index do |row, i|
      build_row(row, i)
    end
  end

  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = colors_for(i, j)
      piece.to_s.colorize(color_options)
    end
  end

  def colors_for(i, j)
    if [i, j] == @cursor_pos
      bg = :light_red
    elsif (i + j).odd?
      bg = :black
    else
      bg = :light_black
    end
    { background: bg, color: :white }
  end

  def render
    system("clear")
    puts @message if @message
    puts "Arrow keys, WASD, or vim to move, space or enter to confirm."
    build_grid.each { |row| puts row.join }
  end
end
