require_relative 'lib/board'
require_relative 'lib/human_player'
require_relative 'lib/Display'
class Game

  def initialize(board = Board.new, players = [HumanPlayer.new("Jim", :white),
    HumanPlayer.new("Sally", :black)])
    @players = players
    @board = board
    @display = Display.new(@board)
    @message = nil
  end

  def current_player
    @players[0]
  end

  def current_color
    current_player.color
  end

  def check_check
    message = ""
    if @board.in_check?(current_color)
      message = "Check!\n"
    else
      message = ""
    end

    message += "#{color_string} to move"
    @display.message = message
  end

  def color_string
    color_string = current_color.to_s
    color_string[0] = color_string[0].upcase
    color_string
  end

  def take_turn
    begin
      start_pos = get_user_input
      raise ArgumentError if @board.color(start_pos) != current_color
      piece = @board[start_pos]
      moves = piece.valid_moves
      # get king castling moves if valid
      moves.concat(@board.check_castling(piece))
      @display.moves = moves
      @display.render
      end_pos = get_user_input
      resp = @board.move(start_pos, end_pos)
      if resp == :promote
        piece_type = get_piece_type
        @board.piece_spawn(piece_type, end_pos, current_color)
      end
      @display.moves = []
    rescue ArgumentError
      @display.moves = []
      @display.render
      puts "Invalid move"
      retry
    end
  end

  def play
    game_over = @board.over?(current_color)
    until game_over
      check_check
      @display.render
      take_turn
      player_swap!
      game_over = @board.over?(current_color)
    end
    @display.render
    end_game(game_over)

  end

  def end_game(status)
    case status
    when :stalemate
      puts "Stalemate - draw"
    when :checkmate
      player_swap!
      puts "Checkmate: #{color_string} wins"
    else
      raise "Error - unexpected game over"
    end
  end

  def get_piece_type
    type = nil
    pieces = ['Q','R','B','N']
    until pieces.include?(type)
      puts "What type of piece do you want? (Q,R,B,N)"
      type = gets.chomp.upcase
    end
    type
  end

  def player_swap!
    @players.rotate!
  end

  def get_user_input
    input = @display.get_input
    until input
      input = @display.get_input
    end
    input
  end

end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end
