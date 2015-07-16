require_relative 'board'
require_relative 'player'
require 'io/console'

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
      current_player = @players.first
      current_player.play_turn(@board)
      @players.rotate!
      if @board.checkmate?(:white)
        puts "#{@player1.color.to_s.capitalize} is in checkmate! #{@player2.color.to_s.capitalize}, you win!".center(62).colorize(:orange)
        exit
      elsif @board.checkmate?(:black)
        puts "#{@player2.color.to_s.capitalize} is in checkmate! #{@player1.color.to_s.capitalize}, you win!".center(62).colorize(:orange)
        exit
      end
    end
  end
end

game = Game.new
game.play
