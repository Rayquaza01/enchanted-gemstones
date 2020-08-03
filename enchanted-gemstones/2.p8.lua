-- high scores
-- game_screen 3

function high_score_cursor(n)
	local this = make_cursor(n)

	this.get_x = function()
		local x = 0
		if (this.selected == 0) then
			x += 48
		else
			x += 11
		end

		x += (timer % 30 > 15) and 1 or 0

		return x
	end

	this.draw = function()
		spr(8, this.get_x(), 13, .5, .5, this.selected == 1, false)
	end

	return this
end

function init_high_scores()
	hs_cursor = high_score_cursor(2)
end

function update_high_scores()
	if (btnp(➡️)) hs_cursor.add(1)
	if (btnp(⬅️)) hs_cursor.add(-1)
	if (btnp(🅾️) or btnp(❎)) game_screen = 1
end

function draw_high_scores()
	print("★high scores", 6, 4, 10)

	print(mode_text[hs_cursor.selected + 1], 16, 13, 4)
	hs_cursor.draw()

	for i = 1, 5, 1 do
		print(scores[hs_cursor.selected + 1][i].name, 12, 17 + (6 * i), 7 + i)
		print(left_pad(tostr(scores[hs_cursor.selected + 1][i].score), 5, "0"), 32, 17 + (6 * i), 7 + i)
	end

	print("🅾️ to go back", 6, 59, 7)
end
