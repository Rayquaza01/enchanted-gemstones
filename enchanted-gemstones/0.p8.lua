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
	timer = 0

	level = 0
	mode = 0
	mode_text = {"marathon", " endless"}

	name_cursor = make_cursor(3)
	name_char_cursor = make_cursor(#lookup)

	init_menu()

	init_high_scores()

	init_game()
end


function _update()
	timer += 1

	if (game_screen == 1) then
		update_menu()
	elseif (game_screen == 2) then
		update_high_scores()
	elseif(game_screen == 3) then
		update_game()
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
	end
end

-- misc functions

function change_screen(gs)
	if (gs == 3) then
		reset_game()
	end

	game_screen = gs
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
