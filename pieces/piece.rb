# Piece Base Class
class Piece
  DIAGONAL_DIRS = [
    [-1, -1], [-1, 1], [1, -1], [1, 1]
  ].freeze
  HORIZONTAL_DIRS = [
    [0, -1], [0, 1]
  ].freeze
  VERTICAL_DIRS = [
    [-1, 0], [1, 0]
  ].freeze
  attr_accessor :board, :pos, :color

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color
    @board.add_piece(pos, self)
  end

  def inspect
    "{ #{self.class} #{@pos} #{@color} }"
  end

  def render
    symbols[@color]
  end

  def move_into_check?(pos)
    return false unless in_bounds?(pos)

    duplicate_board = @board.dup
    duplicate_board.move!(@pos, pos, true)
    duplicate_board.in_check?(@color)
  end

  def valid_moves
    moves.reject do |move|
      move_into_check?(move)
    end
  end

  def in_bounds?(new_pos)
    new_pos[0] < 8 && new_pos[1] < 8 && new_pos[0] >= 0 && new_pos[1] >= 0
  end

  def same_color?(other_piece)
    @color == other_piece.color
  end
end
