# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'stepable'

class Knight < Piece
  include Stepable

  def symbols
    { white: '♘', black: '♞' }
  end
  
  protected
  def directions
    [
      [ 1,  2],
      [ 1, -2],
      [ 2, -1],
      [ 2,  1],
      [-2,  1],
      [-2, -1],
      [-1,  2],
      [-1, -2],
    ]
  end
end
