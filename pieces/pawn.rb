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

  def at_end_row?
    (color == :white && pos[0].zero?) ||
      (color == :black && pos[0] == 7)
  end

  def moves
    straight_steps + diag_attacks + en_passants
  end

  def straight_steps
    straight_moves = []
    cx, cy = pos
    dx, dy = [cx + forward_dir, cy]
    straight_moves << [dx, dy] if in_bounds?([dx, dy]) && board.empty?([dx, dy])

    dx += forward_dir
    straight_moves << [dx, dy] if at_start_row? && board.empty?([dx, dy])

    straight_moves
  end

  def diag_moves
    diag_moves = []
    cx, cy = pos
    dx = cx + forward_dir
    [-1, 1].each do |dy|
      diag_moves << [dx, cy + dy] if in_bounds?([dx, cy + dy])
    end

    diag_moves
  end

  def diag_attacks
    diag_moves.select do |x, y|
      !board.empty?([x, y]) && board[[x, y]].color != color
    end
  end

  def en_passants
    diag_moves.select do |_, dy|
      cur_x = pos[0]
      adj_pos = [cur_x, dy]
      !board.empty?(adj_pos) && board[adj_pos].color != color &&
        board[adj_pos].is_a?(Pawn) && board[adj_pos].en_passant
    end
  end

  def forward_dir
    color == :white ? -1 : 1
  end
end
