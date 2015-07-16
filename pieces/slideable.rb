module Slideable

  STRAIGHTMOVES = [
    [0,  1],
    [1,  0],
    [0, -1],
    [-1, 0]
    ]

  DIAGMOVES = [
    [1,   1],
    [-1,  1],
    [1,  -1],
    [-1, -1],
  ]

  def moves
    moves = []
    directions.each do |dir|
      dx, dy = dir
      new_pos = [pos[0] + dx, pos[1] + dy]

      while in_bounds?(new_pos) do
        board_piece = self.board[new_pos]
        if board_piece && self.same_color?(board_piece)
          break
        elsif board_piece && !self.same_color?(board_piece)
          moves << new_pos
          break
        elsif board_piece.nil?
          moves << new_pos
        end
        new_pos = [new_pos[0] + dx , new_pos[1] + dy]
      end
    end
    moves
  end

  def straightmoves
    STRAIGHTMOVES
  end

  def diagmoves
    DIAGMOVES
  end

end
