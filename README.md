# TetrisGame
Tetris IOS application using swift. 

Background:
The purpose of this assignment is to use basic swift programming and using SwiftUI and touch
and multi-touch gestures. This project assignment is based on tutorials 14 and 15 as well as
SwiftUI basics. In this assignment we will build a tetris clone game that utilizes touch gestures to
control placements and rotations of blocks.
Game mechanic and information can be found here for reference:
https://tetris.fandom.com/wiki/Tetris_Wiki
R1.1: The game must be built on Xcode 12.x, and Swift 5 or later and must utilize apple's
SwiftUI to design the UI of the game.
R1.2: On app startup the game should launch with an empty background and begin by spawning
random tetris blocks at the top of the game. Each unique block labeled I, J, L, O, S, T, Z must
have equal randomness of spawning.
R1.3: When a random block is spawned it must then fall slowly to the bottom of the screen
where it is then placed wherever it has landed.
R1.4: When a block falls it must be placed on the spot where it has landed, either at the bottom
of the game screen, or on top of a block that has already been placed.
R1.5: The player must be able to rotate a spawned block using a tap gesture or a by being able to
rotate the block using both fingers around the block and drag in a rotating motion to rotate the
block.
R1.6: The player must be able to use touch gestures to drag the block along the x-axis of the
game board to be able to specify where along the game the block must be placed. This means
that the player must be able to move the falling block horizontally as it falls.
R1.7: The player must be able to use a touch gesture to drag the block down and place the block
at specified destination point. When the block falls or is dragged to the bottom of the screen it
must be placed.
For reference of how rotation system works for tetris blocks: https://tetris.fandom.com/wiki/SRS
R1.8: The game must be able to handle wall kicks, meaning that it must keep into account
possible rotations in reference to the space available around walls and other blocks.
For reference on wall kicks: https://tetris.fandom.com/wiki/Wall_kick
R1.9: The game must show a shaded phantom block at the point of possible location that the
block will be placed, this phantom block will replicate the rotation set by the player and mirror
the point of the block relative to the x axis. Showing where the block will be placed.
R.1.10: The game must work that a line will be cleared if a horizontal line of the game board is
filled, this will cause the game to clear the line and drop all the lines above down by one rank. If
the blocks fill the game board or get to the point where no more blocks are able to be placed on
the game board then the game is over and the game should stop. Signal the end of the game in
the console
