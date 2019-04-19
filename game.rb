#! /usr/bin/env ruby

require_relative 'board'
require_relative 'player'
require 'io/console'

# Game class
class Game
  attr_reader :board

  def initialize(highlighting: false)
    @board = Board.new(false, highlighting)
    @player1 = HumanPlayer.new(:white)
    @player2 = HumanPlayer.new(:black)
    @players = [@player1, @player2]
  end

  def play
    loop do
      @players.first.play_turn(@board)

      if @board.checkmate?(@players.last.color)
        puts "#{@players.last.color.to_s.capitalize} is in checkmate! #{@players.first.color.to_s.capitalize}, you win!"
          .center(62).colorize(:orange)
        exit
      end

      @players.rotate!
    end
  end
end

if $PROGRAM_NAME == __FILE__
  enable_hl = ARGV.include?('--hl')
  game = Game.new(highlighting: enable_hl)
  game.play
end
