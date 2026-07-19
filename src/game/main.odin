package game

import rl "vendor:raylib"
import "core:log"

Position :: [2]u32
Vec2 :: rl.Vector2

main :: proc() {
	BOARD_CELL_COUNT :: 15

	context.logger = log.create_console_logger()
	rl.InitWindow(1280, 720, "nonogramination")

	board := new_board_randomized(BOARD_CELL_COUNT)

	hot_cell : Maybe(Position) = nil

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		draw_board(board)

		new_hot_cell := get_hot_cell(board)
		if new_hot_cell != hot_cell {
			log.info("hot cell:", new_hot_cell)
		}
		hot_cell = new_hot_cell

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
