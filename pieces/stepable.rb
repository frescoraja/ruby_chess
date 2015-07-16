module Stepable

  def moves
    moves = []
    directions.each do |dir|
      cur_x, cur_y = pos
      new_pos = [cur_x + dir[0], cur_y + dir[1]]

      next unless board.valid_position?(new_pos)

      if board.empty?(new_pos)
        moves << new_pos
      elsif board[new_pos].color != color
        moves << new_pos
      end
    end
    moves
  end
end
