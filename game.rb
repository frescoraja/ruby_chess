#! /usr/bin/env ruby

require_relative 'board'
require_relative 'player'
require 'io/console'

# Game class
class Game
  attr_reader :board

  def initialize
    @board = Board.new(false)
    @player1 = HumanPlayer.new(:white)
    @player2 = HumanPlayer.new(:black)
    @players = [@player1, @player2]
  end

  def play
    puts "Let's Play CHESS!!"
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
  game = Game.new
  game.play
end
