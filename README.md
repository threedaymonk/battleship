Battleship
==========

The game
--------

Long version: see [Wikipedia](https://secure.wikimedia.org/wikipedia/en/wiki/Battleship_(game\))

* Each player starts with a fleet of 5 ships, of length 5, 4, 3, 3, and 2.
* Each player places their ships horizontally or vertically on a 10x10 grid; this is not visible to their opponent.
* Players take turns to fire at positions on the grid, gradually revealing where their opponent’s ships are and are not located.
* A ship is destroyed when every cell of a ship has been hit.
* The winner is the first player to destroy their opponent’s fleet.

You lose if:

* You do not place the correct number and size of ships.
* You place your fleet in impossible positions (ships overlapping or partly off the board).
* Your code raises an exception.
* All your ships have been sunk.

### Additional rules

* The official interpreter is Ruby 1.9.2.
* The player will not have access to the game objects.
* The player may `require` Ruby source files from within a `lib` directory in the same place as the player file (i.e. `players/player.rb` can use `players/lib/foo/bar.rb` via `require "foo/bar"`.)
* A file should not implement more than one player class.
* The judge’s decision is final.

Implementation
--------------

Play takes place on a 10x10 grid. Co-ordinates are given in the order _(x,y)_
and are zero-indexed relative to the top left, i.e. _(0,0)_ is the top left,
_(9,0)_ is the top right, and _(9,9)_ is the bottom right.

A player is implemented as a Ruby class. The name of the class must be unique
and end with `Player`. It must implement the following instance methods:

### name

This must return an ASCII string containing the name of the team or player.

### new_game

This is called whenever a game starts. It must return the initial positioning
of the fleet as an array of 5 arrays, one for each ship. The format of each array is:

    [x, y, length, orientation]

where `x` and `y` are the top left cell of the ship, length is its length
(2-5), and orientation is either `:across` or `:down`.

### take_turn(state, ships_remaining)

`state` is a representation of the known state of the opponent’s fleet, as
modified by the player’s shots. It is given as an array of arrays; the inner
arrays represent horizontal rows. Each cell may be in one of three states:
`:unknown`, `:hit`, or `:miss`. E.g.

    [[:hit, :miss, :unknown, ...], [:unknown, :unknown, :unknown, ...], ...]
    # 0,0   1,0    2,0              0,1       1,1       2,1

`ships_remaining` is an array of the ships remaining on the opponent's board,
given as an array of numbers representing their lengths, longest first.
For example, the first two calls will always be:

    [5, 4, 3, 3, 2]

If the player is lucky enough to take out the length 2 ship on their first two
turns, the third turn will be called with:

    [5, 4, 3, 3]

and so on.

`take_turn` must return an array of co-ordinates for the next shot. In the
example above, we can see that the player has already played `[0,0]`, yielding
a hit, and `[1,0]`, giving a miss. They can now return a reasonable guess of
`[0,1]` for their next shot.

The console runner
------------------

A console runner is provided. It can be started using:

    ruby bin/play.rb path/to/player_a.rb path/to/player_b.rb

Players are isolated using DRb.

A couple of very basic players are supplied: `StupidPlayer` puts all its ships
in a corner and guesses at random (often wasting turns by repeating itself).
`Human Player` asks for input via the console.
