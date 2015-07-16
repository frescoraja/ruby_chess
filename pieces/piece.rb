class Piece
  DIAGONAL_DIRS = [
    [-1, -1], [-1, 1], [1, -1], [1, 1]
  ]
  HORIZONTAL_DIRS = [
    [0, -1], [0, 1]
  ]
  VERTICAL_DIRS = [
    [-1, 0], [1, 0]
  ]
  attr_accessor :board, :pos, :color

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color
    @board.add_piece(pos, self)
  end

  def inspect
    "{ #{self.class} #{self.pos} #{self.color} }"
  end

  def render
    symbols[@color]
  end

  def move_into_check?(pos)
    duplicate_board = @board.dup
    duplicate_board.move!(self.pos, pos)
    duplicate_board.in_check?(@color)
  end

  def valid_moves
    self.moves.reject do |move|
      self.move_into_check?(move)
    end
  end

  def in_bounds?(new_pos)
    new_pos[0] < 8 && new_pos[1] < 8 && new_pos[0] >= 0 && new_pos[1] >= 0
  end

  def same_color?(other_piece)
    self.color == other_piece.color
  end
end
