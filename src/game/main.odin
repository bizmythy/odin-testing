package game

import logger "../logger"
import screenshot "../screenshot"
import "core:log"
import number_font "number_font"
import rl "vendor:raylib"

// Position on board cells. Column then row.
Position :: [2]u32

Vec2 :: rl.Vector2

// Configure raylib window for the application
raylib_start :: proc() {
	rl.SetConfigFlags({.WINDOW_HIGHDPI})
	rl.InitWindow(1280, 720, "nonogramination")
}

main :: proc() {
	SETTINGS :: Board_Settings {
		count            = 10,
		history_capacity = 100,
		corner           = Vec2{100, 100},
		cell_size        = 50,
	}

	context.logger = logger.init()
	defer logger.destroy()

	raylib_start()
	defer rl.CloseWindow()

	number_font.load()
	defer number_font.unload()

	board := new_board_randomized(SETTINGS)
	defer destroy_board(&board)

	hot_cell: HotPosition = nil

	for !rl.WindowShouldClose() {
		// Input
		mouse_pos := get_mouse_pos()
		new_hot_cell := get_hot_cell(board, mouse_pos)
		if new_hot_cell != hot_cell {
			log.debug("hot cell:", new_hot_cell)
		}
		hot_cell = new_hot_cell

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		draw_board(board, hot_cell)

		rl.EndDrawing()

		handle_mouse(board, hot_cell)
		screenshot.run()
	}

}
