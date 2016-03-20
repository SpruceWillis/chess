require_relative 'board'
require_relative 'human_player'
require_relative 'Display'
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

  def reset_message
    @display.message = nil
  end

  def check_check
    if @board.in_check?(current_color)
      @display.message = "Check!"
    else
      reset_message
    end
  end

  def play
    until @board.in_checkmate?(current_color)
      check_check
      @display.render
      begin
        puts "#{current_player.name}, select your piece"
        start_pos = get_user_input
        raise ArgumentError if @board.color(start_pos) != current_color
        puts "#{current_player.name}, where do you want it?"
        end_pos = get_user_input
        resp = @board.move(start_pos, end_pos)
        if resp == :promote
          piece_type = get_piece_type
          @board.piece_spawn(piece_type, end_pos, current_color)
        end
      rescue ArgumentError
        retry
      end
      player_swap!
    end
    player_swap!
    puts "Congratulations #{current_player.name}, you won!"
  end

  def get_piece_type
    type = nil
    pieces = ['Q','R','B','N']
    until pieces.include?(type)
      # byebug
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
