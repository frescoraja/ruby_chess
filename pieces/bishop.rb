# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

class Bishop < Piece
  include Slideable

  def symbols
     { white: '♗', black: '♝' }
  end
  protected
  def directions
    diagmoves
  end
end
