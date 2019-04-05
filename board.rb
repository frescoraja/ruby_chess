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

class InvalidStartMove < ArgumentError
end
class InvalidEndMove < ArgumentError
end

# Board Class
class Board
  attr_reader :rows
  attr_accessor :selected, :cursor_color, :current_piece
  def initialize(fill_board = true)
    make_blank_board(fill_board)
    @selected = [7, 0]
    @current_piece = nil
    @cursor_color = :light_blue
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
        next unless piece

        type = piece.class
        color = piece.color
        position = piece.pos
        type.new(new_board, position, color)
      end
    end

    new_board
  end

  def in_check?(color)
    king_pos = find_king(color).pos
    pieces.any? { |piece| piece.moves && piece.moves.include?(king_pos) }
  end

  def checkmate?(color)
    return unless in_check?(color)

    comrades = pieces.select { |piece| piece.color == color }
    comrades.none? { |comrade| comrade.valid_moves.count > 0 }
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
    pawn.en_passant = (start[0] - end_pos[0]).abs == 2
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
    @rows = Array.new(8) { Array.new(8) }
    return if fill_board

    %i[white black].each do |symbol|
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
    @current_piece = nil
  end

  def move(start, end_pos)
    start_piece = self[start]

    raise InvalidEndMove, 'Not a valid selection.' if start_piece.nil?
    raise InvalidEndMove, 'Not a valid move.' unless start_piece.moves.include?(end_pos)
    raise InvalidEndMove, 'Cannot move into check.' unless start_piece.valid_moves.include?(end_pos)

    move!(start, end_pos)
  end

  def valid_position?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def start_move_pos(color)
    @selected = color == :white ? [4, 4] : [5, 3]
  end

  def choose_piece(color)
    chosen_piece = self[@selected]
    raise InvalidStartMove, 'No piece selected.' if chosen_piece.nil?
    raise InvalidStartMove, 'Not your piece!' if chosen_piece.color != color
    raise InvalidStartMove, 'No available moves for this piece' if chosen_piece.valid_moves.empty?

    @current_piece = chosen_piece
  end

  def unchoose_piece
    @current_piece = nil
  end

  def _render_caption(color)
    in_check_msg = in_check?(color) ? " - (in Check)".center(62).colorize(:red) : ""
    puts "\nCurrent Player: #{color.capitalize}#{in_check_msg}".center(62).colorize(cursor_color)
    puts 'w,a,s,d to navigate, ENTER to select'.center(62).colorize(cursor_color)
    puts 'q to Exit'.center(62).colorize(:yellow)
  end

  def render(active_color)
    system 'clear'
    puts "\n\n"
    moves_pos = []
    if @current_piece && @current_piece.color == active_color
      moves_pos = @current_piece.valid_moves
    elsif self[@selected] && self[@selected].color == active_color
      moves_pos = self[@selected].valid_moves
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
        background = counter.odd? ? :black : :white

        if @selected == [row_idx, col_idx]
          background = @cursor_color
        elsif @current_piece && @current_piece.pos == [row_idx, col_idx]
            background = :magenta
        end

        if moves_pos.include?([row_idx, col_idx])
          if piece
            if @selected == [row_idx, col_idx] && @current_piece && piece.color != @current_piece.color
              background = :red
            elsif (@current_piece && @current_piece.color != piece.color) ||
                  (!empty?(@selected) && self[@selected].color != piece.color)
              background = :light_red
            else
              background = :light_yellow
            end
          else
            if @selected == [row_idx, col_idx]
              background = :light_magenta
            else
              background = :light_yellow
            end
          end
        end

        top_row_str += "".center(7).colorize(background: background)
        bottom_row_str += "".center(7).colorize(background: background)
        if piece
          row_str += "#{piece.render}".center(7).colorize(
            color: "light_#{piece.color}", background: background)
        else
          row_str += "".center(7).colorize(background: background)
        end
      end
      puts top_row_str
      puts row_str
      puts bottom_row_str
      counter += 1
    end
    puts '     A      B      C      D      E      F      G      H'

    _render_caption(active_color)
    nil
  end
end
