-- game board
-- game_screen 3

function find_adjacent(x, y, d, collision)
	local adj = {}
	adj.x = x + dx[d]
	adj.y = y + dy[d]

	-- if adj is outside the bounds of the board
	if (adj.y > game.height or adj.y < 1 or adj.x > game.width or adj.x < 1) then
		return false
	end

	-- if adj is already filled
	if (collision and ((game.board[adj.y][adj.x] & color_mask) > 0)) then
		return false
	end

	return adj
end

function make_countdown(n)
	local this = {}
	-- maximum value of countdown
	this.max = n
	-- current value
	this.val = n

	-- subtract s from current value
	this.subtract = function(s)
		this.val -= s
	end

	-- reset current value to max
	this.reset = function()
		this.val = this.max
	end

	-- if current value less than 0, reset countdown
	-- and return true
	this.is_finished = function()
		if (this.val <= 0) then
			this.reset()
			return true
		end
		return false
	end

	return this
end

function make_blocks(special, valid)
	local this = {}

	-- block starting position (bottom block)
	this.x = 4
	this.y = 1

	-- if blocks are still movable
	this.valid = valid

	this.blocks = {}
	-- fill blocks
	for i = 1, 3, 1 do
		if (special) then
			this.blocks[i] = 7
		else
			this.blocks[i] = roll_die()
		end
	end

	-- place blocks on board
	this.lock = function()
		current = {y=this.y, x=this.x}
		for i = 3, 1, -1 do
			if (current) then
				game.board[current.y][current.x] = this.blocks[i]
				current = find_adjacent(current.x, current.y, 1, false)
			end
		end
		game.active.valid = false
		game.state = 1
	end

	-- move left and right
	this.movex = function(d)
		local direction
		if (d == 1) direction = 3
		if (d == -1) direction = 7
		local adj = find_adjacent(this.x, this.y, direction, true)
		if (adj) then
			this.y = adj.y
			this.x = adj.x
		end
	end

	-- move down
	-- if lock is true, the blocks will lock into place if possible
	-- if query is true, this will return if the blocks are lockable
	this.movey = function(lock, query)
		local adj = find_adjacent(this.x, this.y, 5, true)
		if (not query and adj) then
			this.y = adj.y
			this.x = adj.x
			return false
		else
			-- lock if allowed
			if (lock) this.lock()
			-- return true if lockable
			return true
		end
	end

	this.rotate = function()
		add(this.blocks, this.blocks[3], 1)
		deli(this.blocks, 4)
	end

	this.rotate_reverse = function()
		add(this.blocks, this.blocks[1], 4)
		deli(this.blocks, 1)
	end

	return this
end

-- draw tile on board
-- co-ords based on game.board
function draw_tile(x, y, val)
	if (val == 0) return
	spr(val, 4 * x + 16, 4 * y + 4, .5, .5)
end


function reset_game()
	to_remove = {}

	-- was button held
	left_held = false
	right_held = false
	down_held = false
	-- auto repeat rate
	-- frames between repeats
	arr = make_countdown(5)
	rep = false

	special_countdown = make_countdown(100)
	level_countdown = make_countdown(100)
	drop_countdown = nil
	lock_countdown = make_countdown(30)

	game = {}
	game.width = 6
	game.height = 13

	game.active = make_blocks(false, false)
	game.next = make_blocks()

	game.over = false

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

function init_game()
	dy = {-1, -1, 0, 1, 1, 1, 0, -1}
	dx = {0, 1, 1, 1, 0, -1, -1, -1}

	to_remove = 0x80
	chain_up = 0x40
	chain_ur = 0x20
	chain_r = 0x10
	chain_dr = 0x08
	color_mask = 0x07
end

function update_game()
	-- block is falling
	if (game.state == 0) then
		if (game.board[1][4] != 0) then
			game.over = true
			return
		end

		-- if no drop countdown (game/level just started)
		if (drop_countdown == nil) then
			drop_countdown = make_countdown(flr(-3 * game.level + 31))
		end
		-- if current active tile is invalid
		if (not game.active.valid) then
			-- move next to active, make new next
			game.active = game.next
			game.next = make_blocks(special_countdown.is_finished(), true)
			return
		end

		-- if press up
		if (btnp(⬆️)) then
			-- hard drop
			while (game.active.valid) do
				game.active.movey(true)
			end
		end

		-- if tile is at bottom
		if (drop_countdown.is_finished()) then
			-- move block down, get if lockable
			local lockable = game.active.movey()
			-- if lock timer expired, lock
			if (lockable) then
				if (lock_countdown.is_finished()) game.active.lock()
			-- if not lockable, reset lock timer
			else
				lock_countdown.reset()
			end
		end

		-- if block is on ground, subtract lock timer every frame
		if (game.active.movey(false, true)) then
			lock_countdown.subtract(1)
		-- if block is in air, reset lock timer
		else
			lock_countdown.reset()
		end

		-- subtract drop timer every frame
		drop_countdown.subtract(1)

		-- rotate
		if (btnp(❎)) then
			game.active.rotate()
		elseif (btnp(🅾️)) then
			game.active.rotate_reverse()
		end

		-- if button pressed for first time
		-- mark as held, and do action
		if (btn(➡️) and not right_held) then
			game.active.movex(1)
			right_held = true
		elseif (btn(⬅️) and not left_held) then
			game.active.movex(-1)
			left_held = true
		elseif (btn(⬇️) and not down_held) then
			game.active.movey(true)
			drop_countdown.reset()
			down_held = true
		end

		-- if button released, but was held last frame
		-- mark as unheld and reset arr
		if (not btn(➡️) and right_held) then
			right_held = false
			arr.reset()
		elseif (not btn(⬅️) and left_held) then
			left_held = false
			arr.reset()
		elseif (not btn(⬇️) and down_held) then
			down_held = false
			arr.reset()
		end

		-- if button pressed and was held last frame
		if (btn(➡️) and right_held) then
			arr.subtract(1)
			if (arr.is_finished()) game.active.movex(1)
		elseif (btn(⬅️) and left_held) then
			arr.subtract(1)
			if (arr.is_finished()) game.active.movex(-1)
		elseif (btn(⬇️) and down_held) then
			arr.subtract(1)
			if (arr.is_finished()) then
				game.active.movey(true)
				drop_countdown.reset()
			end
		end
	elseif (game.state == 1) then
		game.state = 0
	end

	-- tmp return to menu
	-- if (btnp(🅾️) or btnp(❎)) game_screen = 1
end

function draw_game()
	map(9, 0)

	-- high score
	print("★", 2, 1, 10)
	print(left_pad(tostr(scores[game.mode + 1][1].score), 5, "0"), 10, 1, 10)

	-- current score
	print(left_pad(tostr(game.score), 5, "0"), 43, 1, 7)

	-- next peice
	print("next", 47, 9, 7)
	for i = 1, 3, 1 do
		spr(game.next.blocks[i], 52, 11 + (4 * i), .5, .5)
	end

	-- gem count
	print("gems", 47, 31, 7)
	print(left_pad(tostr(game.gems), 4, "0"), 47, 37, 7)

	-- level
	print("lvl", 49, 46, 7)
	print(left_pad(tostr(game.level + 1), 2, "0"), 51, 52, 7)

	-- game board
	if (game.active != nil) then
		local current = {x=game.active.x, y=game.active.y}
		for i = 3, 1, -1 do
			if (current) then
				draw_tile(current.x, current.y, game.active.blocks[i])
				current = find_adjacent(current.x, current.y, 1)
			end
		end
	end

	for i = 1, game.height, 1 do
		for j = 1, game.width, 1 do
			draw_tile(j, i, game.board[i][j] & color_mask)
		end
	end
end
