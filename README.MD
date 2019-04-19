# Chess

Two-player graphical command-line chess with move highlighting, written in Ruby.

## Installation

To install, please have ruby 2.3+ installed, clone this repo and run `bundle
install` to install dependencies.  The game executable is `game.rb`

```bash

git clone https://github.com/frescoraja/ruby_chess && cd ruby_chess

bundle install

ruby game.rb
```

## Features

- Valid-move highlighting: move your cursor to a piece to see all valid moves
    for that piece
- [Pawn en-passant attack](https://en.wikipedia.org/wiki/En_passant)
- [Pawn conversion](http://www.4chessrules.com/converting-pawns-into-higher-pieces.html)

## Demo

![Chess Demo](chessgame.gif)
