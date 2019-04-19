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

  def initialize(fill_board = true, highlighting = false)
    make_blank_board(fill_board)
    @selected = [7, 0]
    @current_piece = nil
    @cursor_color = :light_blue
    @highlight_moves = highlighting
  end

  def [](pos)
    x, y = pos
    @rows[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @rows[x][y] = piece
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

  def graduate_pawn(pawn)
    _render_graduation_options(pawn) if pawn.at_end_row?
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

  def move!(start, end_pos, checking = false)
    piece = self[start]
    en_passantify(piece, start, end_pos) if piece.is_a?(Pawn)
    perform_passant!(start, end_pos, piece) if piece.is_a?(Pawn) &&
                                               piece.en_passants.include?(end_pos)
    self[end_pos] = piece
    piece.pos = end_pos
    self[start] = nil
    @current_piece = nil
    graduate_pawn(piece) if !checking && piece.is_a?(Pawn)
  end

  def perform_passant!(start, end_pos, piece)
    other_piece = self[[start[0], end_pos[1]]]
    return if other_piece.nil? || other_piece.color == piece.color

    self[other_piece.pos] = nil if other_piece.is_a?(Pawn) && other_piece.en_passant
  end

  def move(start, end_pos, checking = false)
    start_piece = self[start]

    raise InvalidEndMove, 'Not a valid selection.' if start_piece.nil?
    raise InvalidEndMove, 'Not a valid move.' unless start_piece.moves.include?(end_pos)
    raise InvalidEndMove, 'Cannot move into check.' unless start_piece.valid_moves.include?(end_pos)

    move!(start, end_pos, checking)
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

  def _render_graduation_options(pawn)
    puts "\nPawn Graduation Available for Player #{pawn.color.to_s.capitalize}!\n"
      .colorize(:green).center(62)
    puts "Please choose a new piece class:\n"
      .colorize(:light_green).center(62)
    puts "(k-> Knight, r-> Rook, b-> Bishop, q-> Queen)\n"
      .colorize(:light_green).center(62)

    input = $stdin.getch
    new_piece = case input
                when /k|K/
                  Knight
                when /r|R/
                  Rook
                when /b|B/
                  Bishop
                else
                  Queen
                end

    new_piece = new_piece.new(self, pawn.pos, pawn.color)
    self[new_piece.pos] = new_piece
  end

  def _render_caption(color)
    in_check_msg = in_check?(color) ? '(in Check)'.colorize(:red) : ''
    puts "\nCurrent Player: #{color.capitalize}".colorize(:blue) + in_check_msg.colorize(:red).center(62)
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
      top_row_str = '  '
      row_str = "#{idx} "
      bottom_row_str = '  '
      idx -= 1
      row.each_with_index do |piece, col_idx|
        counter += 1
        bg = counter.odd? ? :black : :white

        if @selected == [row_idx, col_idx]
          bg = @cursor_color
        elsif @current_piece && @current_piece.pos == [row_idx, col_idx]
          bg = :magenta
        end

        if @highlight_moves && moves_pos.include?([row_idx, col_idx])
          bg = :light_yellow

          if piece
            bg = :red if (@selected == [row_idx, col_idx] && @current_piece && piece.color != @current_piece.color) ||
                         ((@current_piece && @current_piece.color != piece.color) ||
                         (!empty?(@selected) && self[@selected].color != piece.color))
          elsif @current_piece.is_a?(Pawn) && @current_piece.en_passants.include?([row_idx, col_idx])
            bg = :red
          elsif self[@selected].is_a?(Pawn) && self[@selected].en_passants.include?([row_idx, col_idx])
            bg = :red
          elsif @selected == [row_idx, col_idx]
            bg = :light_magenta
          end
        end

        top_row_str += ''.center(7).colorize(background: bg)
        bottom_row_str += ''.center(7).colorize(background: bg)
        if piece
          row_str += piece.render.center(7).colorize(
            color: "light_#{piece.color}", background: bg
          )
        else
          row_str += ''.center(7).colorize(background: bg) unless piece
        end
      end
      puts top_row_str
      puts row_str
      puts bottom_row_str
      counter += 1
    end
    puts '     ' + ('A'..'H').to_a.join('      ')

    _render_caption(active_color)
    nil
  end
end
