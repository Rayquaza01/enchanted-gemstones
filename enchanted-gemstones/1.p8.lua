-- main menu
-- game_screen 1

-- change screen
function change_screen(gs)
	if (gs == 3) then
		reset_game()
	end

	game_screen = gs
end

function init_menu()
	m_cursor = make_cursor(4)
	menu_gem_colors = {9, 13}
end

function update_menu()
	if (btnp(⬆️)) m_cursor.add(-1)
	if (btnp(⬇️)) m_cursor.add(1)

	if (btnp(🅾️)) then
		if (m_cursor.selected == 0) level = (level + 1) % 20
		if (m_cursor.selected == 1) mode = (mode + 1) % 2
		if (m_cursor.selected == 2) change_screen(2)
		if (m_cursor.selected == 3) change_screen(3)
	end
	if (btnp(➡️)) then
		if (m_cursor.selected == 0) level = (level + 1) % 20
		if (m_cursor.selected == 1) mode = (mode + 1) % 2
	end

	if (btnp(❎)) then
		if (m_cursor.selected == 0) level = (level - 1) % 20
		if (m_cursor.selected == 1) mode = (mode - 1) % 2
		if (m_cursor.selected == 2) change_screen(2)
		if (m_cursor.selected == 3) change_screen(3)
	end
	if (btnp(⬅️)) then
		if (m_cursor.selected == 0) level = (level - 1) % 20
		if (m_cursor.selected == 1) mode = (mode - 1) % 2
	end
end

function draw_menu()
	map(0, 0)
	-- randomize colors every second
	if (frame_counter.selected == 15) then
		menu_gem_colors[1] = roll_die() + 9
		menu_gem_colors[2] = roll_die() + 9
	end

	print("◆", 9, 4, menu_gem_colors[1])
	print("enchanted", 17, 4, 7)
	print("gemstones", 10, 10, 7)
	print("◆", 46, 10, menu_gem_colors[2])

	spr(8, (frame_counter.selected > 14) and 1 or 2, 6 * m_cursor.selected + 22)

	print("level", 6, 22, 7)
	print(left_pad(tostr(level + 1), 2, "0"), 50, 22, 4)

	print("mode", 6, 28, 7)
	print(mode_text[mode + 1], 26, 28, 4)

	print("high scores", 6, 34, 7)
	print("start game", 6, 40, 7)

	print("lowrezjam 2020", 1, 59, 7)
	print("♥", 57, 59, 8)
end
