require_relative 'manifest'
require_relative 'steppable'
require 'Colorize'
require 'byebug'
class King < Piece

  attr_accessor :has_moved
  include Steppable

  def directions
    dirs = [-1,0,1].product([-1,0,1]).reject{|el| el == [0,0]}
    row = @pos[0]
    dirs << [row, 2] << [row, 6] if [0,7].include?(row)
    return dirs
  end

  def initialize(color, board, pos)
    @has_moved = false
    super
  end

  def to_s
    @color == :white ? ' ♔ ' : ' ♚ '
  end

  def can_castle?(end_pos)
    return false if @board.in_check?(@color) || @has_moved
    # byebug
    row = @pos[0]
    return false unless [2,-2].include?(end_pos[1] - @pos[1])
    if end_pos[1] < @pos[1]
      piece = @board[[row, 0]]
      # byebug
      return false unless piece.is_a?(Rook) && !piece.has_moved
      return false unless @board[[row,3]].empty? && !move_into_check?([row,3])
      return false unless @board[[row,2]].empty? && !move_into_check?([row,2])
      return false unless @board[[row,1]].empty?

    else
      piece = @board[[@pos[0], 7]]
      return false unless piece.is_a?(Rook) && !piece.has_moved
      return false unless @board[[row,5]].empty? && !move_into_check?([row,5])
      return false unless @board[[row,6]].empty? && !move_into_check?([row,6])
    end
    true
  end

  def valid_move?(end_pos)
    (moves.include?(end_pos) && !move_into_check?(end_pos)) ||
      can_castle?(end_pos)
  end

end
