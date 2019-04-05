require_relative 'piece'
require_relative 'slideable'

# Queen Class
class Queen < Piece
  include Slideable

  def symbols
    { white: '♕', black: '♛' }
  end

  protected

  def directions
    straightmoves + diagmoves
  end
end
