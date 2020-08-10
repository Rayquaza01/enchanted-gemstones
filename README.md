# Enchanted Gemstones
A Pico-8 Magic Jewlery/Columns Clone (Submission for [LOWREZJAM 2020](https://itch.io/jam/lowrezjam-2020))

## What is this game?

This game is a clone of [Magic Jewelry](https://en.wikipedia.org/wiki/Columns_(video_game)) (an unlicensed NES game) which is in turn a clone of [Columns](https://en.wikipedia.org/wiki/Columns_(video_game)) (a puzzle game for the Sega Genisis).

It is a match-3 falling block puzzle game. The goal is to place the falling colored gems (blocks) onto the board so that three gems of the same color can match vertically, horizontally, or diagonally.

## How to Play

When the game starts, the bottom of a set of 3 gems will appear in the 1st row, 4th column.
 * The three gems will slowly move downwards towards the bottom of the board.
 * Use ⬅️ and ➡️ to move the gems into the position where you want it.
 * Press ⬇️ to make the gems fall faster, or press ⬆️ to instantly drop the gems to the bottom of the board.
 * Press 🅾️ or ❎ to rotate the order of the gems.

Once a gem reaches the bottom of the board (or collides with another gem from below), there will be 1 second (30 frames) to move rotate or move the gem before it locks into place. Moving the gem to be above blank tile again will refresh the timer. Pressing ⬇️ or ⬆️ will skip the rest of the timer.

If you place 3 or more gems of the same color in a line vertically, horizontally, or diagonally, those gems will break and you will be given points equal to *score multiplier* ⨉ (*number of gems broken* - 2).

Once the gems are broken, any gems left floating will fall down to fill all of the empty space on the board. If this causes 3 gems of the same color to form a line again, the score multiplier will increase and those gems will be removed as well.

Every 50 gems broken, the level will increase (up to level 20) and so will the gems' falling speed.

Every 25 points, a special multi color gem will be given. This gem, when placed above another gem, will break all gems of the same color at once.

The game ends when you top out (a gem is locked in the 1st row, 4th column) or when you complete level 20 (marathon mode only).

# Links

 * [Itch page](https://rayquaza01.itch.io/enchanted-gemstones)
 * [Github Repo](https://github.com/Rayquaza01/enchanted-gemstones)
 * [Play on Github](https://Rayquaza01.github.io/enchanted-gemstones)
 * [LOWREZJAM 2020](https://itch.io/jam/lowrezjam-2020)
