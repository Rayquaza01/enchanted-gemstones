-- game board
-- game_screen 3

function find_adjacent(x, y, d, collision)
	local adj = {}
	adj.x = x + dx[d]
	adj.y = y + dy[d]

	if (adj.y > game.height or adj.y < 1 or adj.x > game.width or adj.x < 1) then
		return false
	end

	if (collision and ((game.board[adj.y][adj.x] & color_mask) > 0)) then
		return false
	end

	return adj
end

function make_countdown(n)
	local this = {}
	this.max = n
	this.val = n

	this.subtract = function(s)
		this.val -= s
	end

	this.reset = function()
		this.val = this.max
	end

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

	this.x = 4
	this.y = 1

	this.valid = valid

	this.blocks = {}
	for i = 1, 3, 1 do
		if (special) then
			this.blocks[i] = 7
		else
			this.blocks[i] = roll_die()
		end
	end

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

function draw_tile(x, y, val)
	if (val == 0) return
	spr(val, 4 * x + 16, 4 * y + 4, .5, .5)
end


function reset_game()
	to_remove = {}

	left_held = false
	right_held = false
	down_held = false
	das = make_countdown(5)
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
	-- if (btnp(⬆️))
	-- if (btnp(⬇️))
	-- if (btnp(➡️))
	-- if (btnp(⬅️))

	if (game.state == 0) then
		if (drop_countdown == nil) then
			drop_countdown = make_countdown(flr(-3 * game.level + 31))
		end
		if (not game.active.valid) then
			game.active = game.next
			game.next = make_blocks(special_countdown.is_finished(), true)
			return
		end

		if (btnp(⬆️)) then
			while (game.active.valid) do
				game.active.movey(true)
			end
		end

		-- if tile is at bottom
		if (drop_countdown.is_finished()) then
			local lockable = game.active.movey()
			if (lockable) then
				if (lock_countdown.is_finished()) game.active.lock()
			else
				lock_countdown.reset()
			end
		end

		if (game.active.movey(false, true)) then
			lock_countdown.subtract(1)
		else
			lock_countdown.reset()
		end

		drop_countdown.subtract(1)

		if (btnp(❎)) then
			game.active.rotate()
		elseif (btnp(🅾️)) then
			game.active.rotate_reverse()
		end

		if (btn(➡️) and not right_held) then
			game.active.movex(1)
			right_held = true
		elseif (btn(⬅️) and not left_held) then
			game.active.movex(-1)
			left_held = true
		elseif (btn(⬇️) and not down_held) then
			game.active.movey(true)
			down_held = true
		end

		if (not btn(➡️) and right_held) then
			right_held = false
			das.reset()
			arr.reset()
		elseif (not btn(⬅️) and left_held) then
			left_held = false
			das.reset()
			arr.reset()
		elseif (not btn(⬇️) and down_held) then
			down_held = false
			das.reset()
			arr.reset()
		end

		if (btn(➡️) and right_held) then
			if (not rep) then
				das.subtract(1)
				if (das.is_finished()) rep = true
			else
				arr.subtract(1)
				if (arr.is_finished()) game.active.movex(1)
			end
		elseif (btn(⬅️) and left_held) then
			if (not rep) then
				das.subtract(1)
				if (das.is_finished()) rep = true
			else
				arr.subtract(1)
				if (arr.is_finished()) game.active.movex(-1)
			end
		elseif (btn(⬇️) and down_held) then
			if (not rep) then
				das.subtract(1)
				if (das.is_finished()) rep = true
			else
				arr.subtract(1)
				if (arr.is_finished()) then
					game.active.movey(true)
					drop_countdown.reset()
				end
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
