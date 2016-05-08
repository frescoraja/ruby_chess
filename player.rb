class HumanPlayer
  attr_reader :color
  def initialize(color)
    @color = color
  end

  def play_turn(board)
    if @color == :white
      board.cursor_color = :light_blue
      board.selected = [6 ,3]
    else
      board.cursor_color = :light_cyan
      board.selected = [1, 4]
    end

    board.render(@color)

    begin
    input_start = nil
    error = nil
    selected_piece = nil
    until input_start
      if error
        puts "\n#{error}".center(62).colorize(:red)
      end
      puts ""
      puts "Current Player: #{@color.capitalize}".center(62).colorize(board.cursor_color)
      puts "w,a,s,d to navigate, ENTER selects start position".center(62).colorize(board.cursor_color)
      puts "q to Exit".center(62).colorize(:yellow)
      input = $stdin.getch
      case input
        when "q"
          exit
        when "w"
          board.selected = [(board.selected[0] - 1) % 8, board.selected[1]]
        when "a"
          board.selected = [board.selected[0], (board.selected[1] - 1) % 8]
        when "s"
          board.selected = [(board.selected[0] + 1) % 8, board.selected[1]]
        when "d"
          board.selected = [board.selected[0], (board.selected[1] + 1) % 8]
        when "\r"
          piece = board[[board.selected[0], board.selected[1]]]
          if piece.nil?
            error = "Please select a piece!"
          elsif piece.color != @color
            error = "Not your piece!"
          else
            input_start = board.selected
            board.current_piece, selected_piece = piece, piece
          end
        end
        board.render(@color)
      end

    error = nil
    input_end = nil
    until input_end
      if error
        puts "\n" + error + "\n".center(62).colorize(:red)
      end
      puts ""
      puts "Current Player: #{@color.capitalize}".center(62).colorize(board.cursor_color)
      puts "w,a,s,d to navigate, ENTER selects end position".center(62).colorize(board.cursor_color)
      puts "q to Exit".center(62).colorize(:yellow)
      input = $stdin.getch
      case input
        when "q"
          exit
        when "w"
          board.selected = [(board.selected[0] - 1) % 8, board.selected[1]]
        when "a"
          board.selected = [board.selected[0], (board.selected[1] - 1) % 8]
        when "s"
          board.selected = [(board.selected[0] + 1) % 8, board.selected[1]]
        when "d"
          board.selected = [board.selected[0], (board.selected[1] + 1) % 8]
        when "\r"
          input_end = board.selected
        end
        board.render(@color)
      end
      board.move(input_start, input_end)
      board.current_piece = nil
      board.render(@color)
    rescue ArgumentError => e
      puts "#{e.message} Please try again."
      retry
    rescue RuntimeError => e
      puts "#{e.message} Please try again."
      retry
    end
  end
end
