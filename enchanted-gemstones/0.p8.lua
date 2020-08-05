--columns
--by joe jarvis

function _init()
	printh("--start--")
	-- enable 64 x 64 mode
	poke(0x5f2c, 3)
	cls()

	lookup = "abcdefghijklmnopqrstuvwxyz0123456789!?. "

	cartdata("r01-enchanted-gemstones")

	score_offsets = {1, 21}
	scores = {{}, {}}
	load_scores()

	-- 1: main menu
	-- 2: high scores
	-- 3: game
	game_screen = 1

	level = 0
	mode = 0
	mode_text = {"marathon", " endless"}

	new_high_score = 0

	frame_counter = make_cursor(30)

	init_menu()

	init_high_scores()

	init_game()

	init_new_high_score()
end


function _update()
	frame_counter.add(1)

	if (game_screen == 1) then
		update_menu()
	elseif (game_screen == 2) then
		update_high_scores()
	elseif (game_screen == 3) then
		update_game()
	elseif (game_screen == 4) then
		update_new_high_score()
	end
end

function _draw()
	cls()
	if (game_screen == 1) then
		draw_menu()
	elseif (game_screen == 2) then
		draw_high_scores()
	elseif (game_screen == 3) then
		draw_game()
	elseif (game_screen == 4) then
		draw_new_high_score()
	end
end

-- misc functions

function index_of(tbl, val)
	for i = 1, #tbl, 1 do
		if (tbl[i] == val) return i
	end
	return 0
end

function make_countdown(n)
	local this = {}
	-- maximum value of countdown
	this.max = n
	-- current value
	this.val = n
	-- is enabled
	this.enabled = true

	-- subtract s from current value
	this.subtract = function(s)
		if (this.enabled) this.val -= s
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

function insertion_sort(tbl)
	for i = 1, #tbl, 1 do
		local j = i
		while (j > 1 and tbl[j - 1] > tbl[j]) do
			local tmp = tbl[j]
			tbl[j] = tbl[j - 1]
			tbl[j - 1] = tmp

			j -= 1
		end
	end

	return tbl
end

function left_pad(s, len, append)
	if (#s >= len) return s

	while (#s < len) do
		s = append .. s
	end

	return s
end

function roll_die()
	return 1 + flr(rnd(6))
end

function num_to_char(n)
	return sub(lookup, n + 1, n + 1)
end

function char_to_num(c)
	for i = 0, #lookup - 1, 1 do
		if (c == num_to_char(i)) return i
	end
end

function save_scores()
	for m = 1, 2, 1 do
		local offset = score_offsets[m]
		for i = 0, 19, 1 do
			local idx = flr(1 / 4) + 1
			local charidx = i % 4
			if (charidx < 3) then
				dset(i + offset, char_to_num(sub(scores[m][idx].name, charidx + 1, charidx + 1)))
			else
				dset(i + offset, scores[m][idx].score)
			end
		end
	end
end

function load_scores()
	-- 1st place in 1-4 (21-24)
	-- 2nd place in 5-8 (25-28)
	-- 3rd place in 9-12 (28-32)
	-- 4th place in 13-16 (33-36)
	-- 5th place in 17-20 (37-40)
	for m = 1, 2, 1 do
		local offset = score_offsets[m]
		for i = 0, 19, 1 do
			-- get same index for every 4 numbers
			-- 3 chars + 1 score
			local idx = flr(i / 4) + 1
			-- if char
			if (i % 4 < 3) then
				-- if index is blank, initialize
				if (scores[m][idx] == nil) scores[m][idx] = {name="", score=0}
				-- add char to name
				scores[m][idx].name = scores[m][idx].name .. num_to_char(dget(i + offset))
			-- if score
			else
				scores[m][idx].score = dget(i + offset)
			end
		end
	end
end

function make_cursor(n)
	local this = {}
	this.selected = 0
	this.length = n

	this.add = function(d)
		this.selected += d
		this.selected %= this.length
	end

	return this
end
