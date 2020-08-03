-- game board
-- game_screen 3

function find_adjacent(y, x, d, collision)
	local adj = {}
	adj.y = y + dy[d]
	adj.x = x + dx[d]

	if (adj.y > game.height or adj.y < 1 or adj.x > game.width or adj.width < 1) then
		return false
	end

	if (collision and (game.board[adj.y][adj.x] & color_mask) == 0) then
		return false
	end

	return adj
end

function make_blocks(special)
	local this = {}

	this.posx = 4
	this.posy = 1

	this.blocks = {}
	for i = 1, 3, 1 do
		if (special) then
			this.blocks[i] = 0
		else
			this.blocks[i] = roll_die()
		end
	end

	this.rotate = function()
		add(this.blocks, this.blocks[3], 1)
		deli(this.blocks, 4)
	end

	return this
end

function reset_game()
	to_remove = {}

	game = {}
	game.width = 6
	game.height = 13

	game.x = 20
	game.y = 8

	game.nextx = 52
	game.nexty = 15

	game.timer = 0

	-- states
	-- 0: block is falling and controlled by player
	-- 1: look for chains
	-- 2: chains flash
	-- 3: gravity
	game.state = 0

	game.mode = mode
	game.level = level
	game.gems = 0
	game.score = 0

	game.board = {}
	for i = 1, game.height, 1 do
		game.board[i] = {}
		for j = 1, game.width, 1 do
			game.board[i][j] = 0
		end
	end
end

function update_game()
	game.timer += 1
	-- tmp return to menu
	if (btnp(🅾️) or btnp(❎)) game_screen = 1
end

function draw_game()
	print("★", 2, 1, 10)
	print(left_pad(tostr(scores[game.mode + 1][1].score), 5, "0"), 10, 1, 10)
	print(left_pad(tostr(game.score), 5, "0"), 43, 1, 7)
	print("next", 47, 9, 7)

	print("gems", 47, 31, 7)
	print(left_pad(tostr(game.gems), 4, "0"), 47, 37, 7)

	print("lvl", 49, 46, 7)
	print(left_pad(tostr(game.level + 1), 2, "0"), 51, 52, 7)
end
