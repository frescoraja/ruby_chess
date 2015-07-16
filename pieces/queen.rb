# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

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
