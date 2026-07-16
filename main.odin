package game

import rl "vendor:raylib"

// Location on grid, row then column.
Position :: [2]u32

// 2D vector.
Vec2 :: rl.Vector2


main :: proc() {
	board_size :: 30

	rl.InitWindow(1280, 720, "nonogramination")

	board := new_board(15)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		draw_board(board)
	}

	rl.CloseWindow()
}
