require "Colorize"
require_relative "cursorable"
##Thanks to rglassett on github for this code!
class Display
  attr_accessor :message, :moves
  include Cursorable


  def initialize(board)
    @board = board
    @cursor_pos = [0, 0]
    @message = nil
    @selected_pos = nil
    @moves = []
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
      mode = :blink
    elsif [i,j] == @selected_pos
      bg = :light_green
      mode = :default
    elsif @moves.include?([i,j])
      bg = :light_blue
      mode = :default
    elsif (i + j).odd?
      bg = :black
      mode = :default
    else
      bg = :light_black
      mode = :default
    end
    { background: bg, color: :white, mode: mode }
  end

  def render
    system("clear")
    puts @message if @message
    puts "Arrow keys, WASD, or vim to move, space or enter to confirm."
    build_grid.each { |row| puts row.join }
  end
end
