package game

import "core:log"
import rl "vendor:raylib"

Position :: [2]u32
Vec2 :: rl.Vector2

// Configure raylib window for the application
raylib_start :: proc() {
	rl.SetConfigFlags({.WINDOW_HIGHDPI})
	rl.InitWindow(1280, 720, "nonogramination")
}

main :: proc() {
	BOARD_CELL_COUNT :: 15

	context.logger = log.create_console_logger()

	raylib_start()

	board := new_board_randomized(BOARD_CELL_COUNT)

	hot_cell: HotCell = nil

	for !rl.WindowShouldClose() {
		// Input
		mouse_pos := get_mouse_pos()
		new_hot_cell := get_hot_cell(board, mouse_pos)
		if new_hot_cell != hot_cell {
			log.info("hot cell:", new_hot_cell)
		}
		hot_cell = new_hot_cell

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		draw_board(board)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
