-- high scores
-- game_screen 3

function init_high_scores()
	hs_cursor = make_cursor(2)
end

function update_high_scores()
	if (btnp(➡️)) hs_cursor.add(1)
	if (btnp(⬅️)) hs_cursor.add(-1)
	if (btnp(🅾️) or btnp(❎)) game_screen = 1
end

function draw_high_scores()
	map(0, 0)
	print("★high scores", 6, 4, 10)

	-- mode text
	print(mode_text[hs_cursor.selected + 1], 16, 13, 4)

	-- draw arrow next to text
	local x = 0
	x += (hs_cursor.selected == 0) and 48 or 11
	x += (frame_counter.selected > 14) and 1 or 0
	spr(8, x, 13, .5, .5, hs_cursor.selected == 1, false)

	-- print each high score
	for i = 1, 5, 1 do
		print(scores[hs_cursor.selected + 1][i].name, 12, 17 + (6 * i), 7 + i)
		print(left_pad(tostr(scores[hs_cursor.selected + 1][i].score), 5, "0"), 32, 17 + (6 * i), 7 + i)
	end

	print("🅾️ to go back", 6, 59, 7)
end
