-- game board
-- game_screen 3

function reset_game()
	game = {}
	game.width = 6
	game.height = 15

	game.startx = 4
	game.starty = 3

	game.timer = 0

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

function update_game()
	game.timer += 1
	-- tmp return to menu
	if (btnp(🅾️) or btnp(❎)) game_screen = 1
end

function draw_game()
	print("★", 1, 0, 10)
	print(left_pad(tostr(scores[game.mode + 1][1].score), 5, "0"), 9, 0, 10)
	print(left_pad(tostr(game.score), 5, "0"), 42, 0, 7)
	print("next", 46, 8, 7)

	print("gems", 46, 30, 7)
	print(left_pad(tostr(game.gems), 4, "0"), 46, 36, 7)

	print("lvl", 48, 45, 7)
	print(left_pad(tostr(game.level + 1), 2, "0"), 50, 51, 7)
end
