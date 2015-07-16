# -*- coding: utf-8 -*-
require_relative 'piece'

class Pawn < Piece
  attr_accessor :en_passant

  def initialize(board, pos, color)
    super(board, pos, color)
    @en_passant = false
  end

  def symbols
    { white: '♙', black: '♟' }
  end

  def at_start_row?
  (color == :white && pos[0] == 6) ||
      (color == :black && pos[0] == 1)
  end

  def moves
    straight_steps + diag_attacks + en_passants
  end

  def straight_steps
    straight_moves = []
    cx, cy = pos
    dx, dy = [cx + forward_dir * 1, cy]
    straight_moves << [dx, dy] if board.empty?([dx, dy])
    dx += forward_dir
    if at_start_row? && board.empty?([dx, dy])
      straight_moves << [dx, dy]
    end
    straight_moves
  end

  def diag_attacks
    diag_attacks = []
    cx, cy = pos
    dx = cx + forward_dir
    [-1 , 1].each do |dy|
      if in_bounds?([dx, cy + dy])
        if !board.empty?([dx, cy + dy]) && board[[dx, cy + dy]].color != color
          diag_attacks << [dx, cy + dy]
        end
      end
    end

    diag_attacks
  end

  def en_passants
    []
  end

  def forward_dir
    color == :white ? -1 : 1
  end
end
