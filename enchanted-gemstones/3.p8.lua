-- game board
-- game_screen 3

function is_set(val, bitw)
	return (val & bitw) == bitw
end

function encode_pos(y, x)
	return x - 1 + game.width * (y - 1 + game.height) - game.width * game.height
end

function decode_pos(pos)
	res = {}

	pos += game.width * game.height
	res.x = pos % game.width + 1
	pos = flr(pos / game.width)
	res.y = pos % game.height + 1

	return res
end

function index_of(tbl, val)
	for i = 1, #tbl, 1 do
		if (tbl[i] == val) return i
	end
	return 0
end

function set_add(tbl, v, i)
	if (i == nil) i = #tbl + 1
	if (index_of(tbl, v) > 0) return
	add(tbl, v, i)
end

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

--game state 0
function move_blocks()
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
		if (special_countdown.is_finished()) then
			printh("special")
			game.next = make_blocks(true, true)
		else
			game.next = make_blocks(false, true)
		end
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
end

-- game state 1
function find_chains()
	-- for every tile
	-- starting from bottom left
	for j = 1, game.width, 1 do
		for i = game.height, 1, -1 do -- height starts from bottom for matching chains
			-- if tile is a color
			local current_color = game.board[i][j] & color_mask
			if (current_color > 0 and current_color < 7) then
				-- for each chain direction
				for d = 1, 4, 1 do
					-- chain elements
					local chain = {{x=j, y=i, color=current_color}}
					-- continue until chain is broken
					while (true) do
						-- if chain is not already part of chain in direction
						if (not is_set(game.board[chain[1].y][chain[1].x], chains[d])) then
							-- get adjacent
							local adj = find_adjacent(chain[1].x, chain[1].y, d, false)
							if (adj) then
								-- get adjacent color
								adj.color = game.board[adj.y][adj.x] & color_mask
								-- if colors match, add to chain
								if (chain[1].color == adj.color) then
									add(chain, adj, 1)
								else
									-- break if colors don't match
									break
								end
							else
								-- break if adjacent is invalid
								break
							end
						else
							-- break if chain in this direction already found
							break
						end
					end

					-- if 3 in a row or more found
					if (#chain >= 3) then
						printh("Found chain:")
						for k = 1, #chain, 1 do
							game.board[chain[k].y][chain[k].x] |= remove_flag
							game.board[chain[k].y][chain[k].x] |= chains[d]
							local pos = encode_pos(chain[k].y, chain[k].x)
							set_add(to_remove, pos)
							printh(" " .. pos .. " " .. game.board[chain[k].y][chain[k].x])
						end
					end
				end
			elseif (current_color == 7) then
				game.board[i][j] |= remove_flag
				set_add(to_remove, encode_pos(i, j))
				local adj = find_adjacent(j, i, 5, false)
				if (adj) then
					adj.color = game.board[adj.y][adj.x] & color_mask
				else
					adj = {color=0}
				end
				-- if below color is not 7 or 0, remove all of that color
				if (adj.color > 0 and adj.color < 7) then
					for k = 1, game.height, 1 do
						for l = 1, game.width, 1 do
							if ((game.board[k][l] & color_mask) == adj.color) then
								game.board[k][l] |= remove_flag
								set_add(to_remove, encode_pos(k, l))
							end
						end
					end
				end
			end
		end -- i loop
	end -- j loop
	game.gems += #to_remove
	level_countdown.subtract(#to_remove)
	if (level_countdown.is_finished()) then
		drop_countdown = nil
		game.level += 1
		if (game.level > 9) game.level = 9
	end

	if (#to_remove > 0) then
		local new_score = game.multiplier * (#to_remove - 2)
		game.score += new_score
		-- prevent score from underflowing
		if (game.score < 0) game.score = 32767
		special_countdown.subtract(new_score)

		game.state = 2
		game.multiplier += 1
	else
		game.multiplier = 1
		game.state = 0
	end
end

-- breaks with infinite loop?
function animate_removal()
	animation_countdown.subtract(1)
	animation.add(1)
	-- if (btnp(🅾️) or btnp(❎)) then
	-- 	animation_countdown.subtract(1)
	-- 	animation.add(1)
	-- end
	if (animation_countdown.is_finished()) then
		-- printh("start removal")
		while (#to_remove > 0) do
			-- printh(#to_remove)
			local current = decode_pos(to_remove[1])
			local adj = find_adjacent(current.x, current.y, 1, false)
			if (adj) then
				if (not is_set(game.board[adj.y][adj.x], remove_flag)) then
					game.board[current.y][current.x] = game.board[adj.y][adj.x] & color_mask
				else
					-- defer
					game.board[current.y][current.x] = 0
					add(to_remove, to_remove[1])
				end
				printh("removing current, adding adj")
				printh(game.board[current.y][current.x])
				deli(to_remove, 1)
				game.board[adj.y][adj.x] |= remove_flag
				set_add(to_remove, encode_pos(adj.y, adj.x), 1)
			else
				-- printh("removing current, setting to 0")
				game.board[current.y][current.x] = 0
				deli(to_remove, 1)
			end
		end
		game.state = 1
	end
end

function reset_game()
	animation = make_cursor(6)
	animation_countdown = make_countdown(30)

	to_remove = {}

	-- was button held
	left_held = false
	right_held = false
	down_held = false
	-- auto repeat rate
	-- frames between repeats
	arr = make_countdown(5)

	special_countdown = make_countdown(25)
	level_countdown = make_countdown(50)
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
	game.multiplier = 1

	game.board = {}
	for i = 1, game.height, 1 do
		game.board[i] = {}
		for j = 1, game.width, 1 do
			game.board[i][j] = 0
		end
	end
end

function init_game()
	-- up, up right, right, down right, down, down left, left, up left
	dy = {-1, -1, 0, 1, 1, 1, 0, -1}
	dx = {0, 1, 1, 1, 0, -1, -1, -1}

	remove_flag = 0x80

	chain_u = 0x40
	chain_ur = 0x20
	chain_r = 0x10
	chain_dr = 0x08

	chains = {chain_u, chain_ur, chain_r, chain_dr}
	all_chains = (chain_u | chain_ur | chain_r | chain_dr)

	color_mask = 0x07
end

function update_game()
	-- block is falling
	if (game.state == 0) then
		move_blocks()
	elseif (game.state == 1) then
		find_chains()
	-- flashing objects
	elseif (game.state == 2) then
		animate_removal()
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
	if (game.active.valid) then
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
			if (game.state == 2 and is_set(game.board[i][j], remove_flag)) then
				draw_tile(j, i, animation.selected)
			else
				draw_tile(j, i, game.board[i][j] & color_mask)
			end
		end
	end
end
