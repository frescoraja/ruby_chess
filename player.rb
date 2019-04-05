class HumanPlayer
  attr_reader :color
  def initialize(color)
    @color = color
  end

  def play_turn(board)
    board.start_move_pos(@color)
    board.render(@color)
    start_pos = nil
    end_pos = nil

    begin
      loop do
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
          when "\e"
            board.unchoose_piece
            start_pos = nil
          when "\r"
            if start_pos.nil?
              board.choose_piece(@color)
              start_pos = board.selected
            elsif board.selected == start_pos
              board.unchoose_piece
              start_pos = nil
            else
              end_pos = board.selected
              board.move(start_pos, end_pos)
              break
            end
          end
        board.render(@color)
      end

    rescue InvalidStartMove, InvalidEndMove, RuntimeError => e
      puts "#{e.message} Please try again.".center(62).colorize(:red)
      retry
    end
  end
end
