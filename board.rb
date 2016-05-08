require_relative 'pieces/piece'
require_relative 'pieces/bishop'
require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/pawn'
require_relative 'pieces/queen'
require_relative 'pieces/rook'
require_relative 'pieces/stepable'
require_relative 'pieces/slideable'
require 'colorize'
require 'byebug'

class Board
  attr_reader :rows
  attr_accessor :selected, :cursor_color, :current_piece
  def initialize(fill_board = true)
    make_blank_board(fill_board)
    @selected = [7, 0]
    @current_piece = nil
    @cursor_color = nil
  end

  def [](pos)
    x, y = pos
    @rows[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @rows[x][y]= piece
  end

  def add_piece(pos, piece)
    self[pos] = piece
  end

  def dup
    new_board = Board.new
    @rows.each do |row|
      row.each do |piece|
        if piece
          type = piece.class
          color = piece.color
          position = piece.pos
          type.new(new_board, position, color)
        end
      end
    end

    new_board
  end

  def in_check?(color)
    king_pos = find_king(color).pos
    pieces.any? { |piece| piece.moves && piece.moves.include?(king_pos) }
  end

  def checkmate?(color)
    return if !self.in_check?(color)
    comrades = pieces.select { |piece| piece.color == color }
    !comrades.any? { |comrade| comrade.valid_moves.count > 0 }
  end

  def find_king(color)
    king = pieces.find do |piece|
      piece.is_a?(King) && piece.color == color
    end
    king
  end

  def pieces
    @rows.flatten.compact
  end

  def empty?(pos)
    self[pos].nil?
  end

  def en_passantify(pawn, start, end_pos)
    if (start[0] - end_pos[0]).abs == 2
      pawn.en_passant = true
    else
      pawn.en_passant = false
    end
  end

  def fill_back_rows(symbol)
    back_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    row = symbol == :white ? 7 : 0
    back_pieces.each_with_index do |piece, col|
      piece.new(self, [row, col], symbol)
    end
  end

  def fill_in_pawns(symbol)
    row = symbol == :white ? 6 : 1
    8.times do |col|
      Pawn.new(self, [row, col], symbol)
    end
  end

  def make_blank_board(fill_board)
    @rows = Array.new (8) { Array.new(8) }
    return if fill_board
    [:white, :black].each do |symbol|
      fill_in_pawns(symbol)
      fill_back_rows(symbol)
    end
  end

  def move!(start, end_pos)
    start_piece = self[start]
    en_passantify(start_piece, start, end_pos) if start_piece.is_a?(Pawn)
    self[end_pos] = start_piece
    self[end_pos].pos = end_pos
    self[start] = nil
  end

  def move(start, end_pos)
    start_piece = self[start]
    if start_piece.nil?
     raise ArgumentError, "Not a valid selection"
     return
   elsif !start_piece.moves.include?(end_pos)
     raise ArgumentError, "Not a valid move."
     return
   elsif !start_piece.valid_moves.include?(end_pos)
     raise "Cannot move into check"
     return
   else
     move!(start, end_pos)
   end
  end

  def valid_position?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def selected_piece_moves
    self[@selected].valid_moves
  end

  def render(active_color)
    system 'clear'
    puts "\n\n"
    moves_pos = []
    if self[@selected] && self[@selected].color == active_color
      moves_pos = selected_piece_moves
    end

    counter = 0
    idx = 8
    @rows.each_with_index do |row, row_idx|
      top_row_str = "  "
      row_str = "#{idx} "
      bottom_row_str = "  "
      idx -= 1
      row.each_with_index do |piece, col_idx|
        counter += 1
        background = counter.odd? ? :light_black : :light_white

        if @selected === [row_idx, col_idx]
          background = @cursor_color
        elsif @current_piece
          if @current_piece.pos === [row_idx, col_idx]
            background = :magenta
          end
        end

        if moves_pos.include?([row_idx, col_idx])
          if self[[row_idx, col_idx]] &&
            self[[row_idx, col_idx]].color != self[@selected].color
            background = :red
          else
            background = :light_yellow
          end
        end

        top_row_str += "".center(7).colorize(background: background)
        bottom_row_str += "".center(7).colorize(background: background)
        if piece
          row_str += "#{piece.render}".center(7).colorize(
            color: piece.color, background: background, mode: :bold)
        else
          row_str += "".center(7).colorize(background: background)
        end
      end
      puts top_row_str
      puts row_str
      puts bottom_row_str
      counter += 1
    end
    puts "     A      B      C      D      E      F      G      H"
    return nil
  end
end
