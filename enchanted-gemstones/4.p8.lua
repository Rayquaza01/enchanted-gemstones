-- new high score
-- game_screen 4

function init_new_high_score()
	name_cursor = make_cursor(3)
	name_chars = {
		make_cursor(#lookup),
		make_cursor(#lookup),
		make_cursor(#lookup)
	}
end

function update_new_high_score()
	if (btnp(⬆️)) name_chars[name_cursor.selected + 1].add(-1)
	if (btnp(⬇️)) name_chars[name_cursor.selected + 1].add(1)
	if (btnp(➡️)) name_cursor.add(1)
	if (btnp(⬅️)) name_cursor.add(-1)

	-- O advances cursor until last character
	if (btnp(🅾️) and name_cursor.selected < 2) then
		name_cursor.add(1)
		return
	end

	if (btnp(🅾️) or btnp(❎)) then
		local s = {name="", score=new_high_score}
		for i = 1, 3, 1 do
			s.name = s.name .. num_to_char(name_chars[i].selected)
		end

		add(scores[new_high_score_mode + 1], s, new_high_score_pos)
		deli(scores[new_high_score_mode + 1], 6)
		-- set high score display to current mode
		hs_cursor.selected = new_high_score_mode
		save_scores()

		game_screen = 2
	end
end

function draw_new_high_score()
	print("★new★", 18, 1, 10)
	print("high score", 12, 7, 10)

	print("#", 10, 19, 7 + new_high_score_pos)
	print(new_high_score_pos, 14, 19, 7 + new_high_score_pos)
	print(left_pad(tostr(new_high_score), 5, "0"), 34, 19, 7 + new_high_score_pos)

	local animation = frame_counter.selected > 14 and 1 or 0

	spr(8, 20 + animation, 37, .5, .5, true)
	spr(8, 39 - animation, 37, .5, .5)

	for i = 1, 3, 1 do
		print(num_to_char(name_chars[i].selected), 4 * i + 22, 37, 7)
		if (i == name_cursor.selected + 1) then
			spr(9, 4 * i + 21, 31 + animation, .5, .5, false, true)
			spr(9, 4 * i + 21, 44 - animation, .5, .5)
		end
	end
end
