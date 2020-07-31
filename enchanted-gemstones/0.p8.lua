--columns
--by joe jarvis

function _init()
	printh("--start--")
	-- enable 64 x 64 mode
	poke(0x5f2c, 3)
	cls()

	cartdata("r01-enchanted-gemstones")

	scores = {{}, {}}

	load_scores()

	init_vars()
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

function left_pad(s, len, append)
	if (#s >= len) return s

	while (#s < len) do
		s = append .. s
	end

	return s
end

function roll_die()
	return 1 + flr(rnd(5))
end

function num_to_char(n)
	local lookup = "abcdefghijklmnopqrstuvwxyz0123456789!?. "
	return sub(lookup, n, n + 1)
end

function load_scores()
	local offsets = {1, 21}

	-- 1st place in 1-4 (21-24)
	-- 2nd place in 5-8 (25-28)
	-- 3rd place in 9-12 (28-32)
	-- 4th place in 13-16 (33-36)
	-- 5th place in 17-20 (37-40)
	for m = 1, 2, 1 do
		local offset = offsets[m]
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

function init_vars()
	-- 1: main menu
	-- 2: high scores
	-- 3: game
	game_screen = 1

	menu_gem_colors = {9, 13}

	level = 0
	mode = 0
	mode_text = {"marathon", " endless"}

	name_cursor = make_cursor(3)
	name_char_cursor = make_cursor(27)

	m_cursor = menu_cursor(4)

	hs_cursor = high_score_cursor(2)

	timer = 0
end
