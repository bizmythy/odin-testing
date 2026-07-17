package game

import rl "vendor:raylib"

// Location on grid, row then column.
Position :: [2]u32

// 2D vector.
Vec2 :: rl.Vector2

main :: proc() {
	BOARD_SIZE :: 15

	rl.InitWindow(1280, 720, "nonogramination")

	board := new_board_randomized(BOARD_SIZE)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		draw_board(board)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
