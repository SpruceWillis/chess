require_relative "pieces/manifest"
require 'byebug'

class Board

  def initialize (grid = nil, is_new = true)
    if grid.nil?
      @grid ||= Array.new(8){Array.new(8){Empty_Square.instance}}
      populate if is_new
    else
      @grid = grid
    end
      @prev_move = {}
  end

  def empty?(x,y)
    @grid[x][y].empty?
  end

  def color(pos)
    self[pos].color
  end

  def move(start_pos, end_pos)

    if self[start_pos].valid_move?(end_pos)
      self[end_pos] = self[start_pos]
      self[end_pos].pos = end_pos
      self[start_pos] = Empty_Square.instance
      set_moved(end_pos)

      handle_castling(start_pos, end_pos) if self[end_pos].is_a?(King)
      handle_en_passant(start_pos, end_pos) if en_passant?(end_pos)
      @prev_move = {start_pos: start_pos, end_pos: end_pos}
      return :promote if promotion?(end_pos)

    else
      raise ArgumentError.new("Invalid Move. Try again!")
    end
    nil
  end

  def handle_en_passant(start_pos, end_pos)
    # byebug
    self[[start_pos[0], end_pos[1]]] = Empty_Square.instance
  end

  def handle_castling(start_pos, end_pos)
    return false unless self[end_pos].is_a?(King)
    row = start_pos[0]
    dy = end_pos[1] - start_pos[1]
    case dy
    when 2
      move!([row, 7], [row, 5])
    when -2
      move!([row, 0], [row, 3])
    end
  end

  def promotion?(end_pos)
    self[end_pos].is_a?(Pawn) && [0,7].include?(end_pos[0])
  end

  def set_moved(end_pos)
    self[end_pos].has_moved = true if self[end_pos].is_a?(King)||
      self[end_pos].is_a?(Rook)
  end

  def piece_spawn(piece_type, pos, color)
    case piece_type
      when 'Q'
        self[pos] = Queen.new(color, self, pos)
      when 'R'
        self[pos] = Rook.new(color, self, pos)
      when 'B'
        self[pos] = Bishop.new(color, self, pos)
      when 'N'
        self[pos] = Knight.new(color, self, pos)
      when 'P'
        self[pos] = Pawn.new(color, self, pos)
      end
  end

  def inspect
    render
  end

  def [](pos)
    x, y = pos
    @grid[x][y]
  end

  def []=(pos, mark)
    x,y = pos
    @grid[x][y] = mark
  end

  def populate
    @grid[0] = get_pieces(:black, 0)
    @grid[1] = get_pawns(:black, 1)
    @grid[7] = get_pieces(:white, 7)
    @grid[6] = get_pawns(:white, 6)
  end

  def get_pieces(color, row)
    [Rook.new(color, self,[row,0]),
     Knight.new(color, self, [row,1]),
     Bishop.new(color, self, [row,2]),
     Queen.new(color, self, [row,3]),
     King.new(color, self, [row, 4]),
     Bishop.new(color, self, [row,5]),
     Knight.new(color, self, [row,6]),
     Rook.new(color, self,[row,7])
    ]
  end

  def get_pawns(color, row)
    arr = Array.new(8)
    arr.map.with_index {|el, idx| Pawn.new(color, self, [row, idx])}
  end

  def get_empty_squares
    Array.new(8){Empty_Square.instance}
  end

  def render
    puts "  #{(0..7).to_a.join(' ')}"
    @grid.each_with_index do |row, ind|
      puts "#{ind} #{row.join(' ')}"
    end
  end

  def in_bounds?(x,y)
    is_valid_pos?(x,y)
  end

  def is_valid_pos?(x,y)
    (0..7).to_a.include?(x) && (0..7).to_a.include?(y)
  end

  def pieces
    pieces = []
    @grid.each_index do |i|
      @grid[i].each_index do |j|
        pieces << @grid[i][j] if @grid[i][j].is_a?(Piece)
      end
    end
    pieces
  end

  def find_king_pos(color)
    @grid.each_index do |i|
      @grid[i].each_index do |j|
        return [i,j] if @grid[i][j].is_a?(King) && @grid[i][j].color == color
      end
    end
    raise RuntimeError.new("No King No King lalalala")
  end

  def in_check?(color)
    king_pos = find_king_pos(color)
    enemy_pieces = pieces.select{|piece| piece.color != color}
    enemy_pieces.each do |piece|
      return true if piece.moves.include?(king_pos)
    end
    false
  end

  def in_checkmate?(color)
    return false unless in_check?(color)

  end

  def dup
    new_board = Board.new(nil, false)
    pieces.each do |piece|
      new_board[piece.pos] = piece.class.new(piece.color, new_board, piece.pos)
    end
    new_board
  end


  def move!(start_pos, end_pos)
    self[end_pos] = self[start_pos]
    self[end_pos].pos = end_pos
    self[start_pos] = Empty_Square.instance
  end

  def rows
    @grid
  end

  def en_passant?(pos)
    return false unless @prev_move[:end_pos]
    end_pos = @prev_move[:end_pos]
    dx, dy = pos[0] - end_pos[0], pos[1] - end_pos[1]
    prev_dx = end_pos[0] - @prev_move[:start_pos][0]
    self[end_pos].is_a?(Pawn) && [1,-1].include?(dx) && dy == 0 && [2,-2].include?(prev_dx)
  end

  def over?(color)
    friend_pieces = pieces.select{|piece| piece.color == color}
    if friend_pieces.all?{|piece| piece.valid_moves.empty?}
     in_check?(color) ? (return :checkmate) : (return :stalemate)
    end
    false
  end

  def check_castling(piece)
    if piece.is_a?(King) && !piece.has_moved
      positions = [
        [0,6],
        [0,2],
        [7,6],
        [7,2] ]
      positions.select{|el| piece.can_castle?(el)}
    else
      []
    end
  end

end



if __FILE__ == $PROGRAM_NAME
  # b = Board.new
  # b.move([6,6],[4,6])
  # b.move([6,5],[5,5])
  # b.move([1,4],[3,4])
  # b.move([0,3],[4,7])
  # b.render
  # p b.in_checkmate?(:white)
end
