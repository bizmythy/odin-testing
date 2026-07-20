package game

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
		count     = 10,
		corner    = Vec2{100, 100},
		cell_size = 50,
	}

	context.logger = log.create_console_logger()

	raylib_start()
	defer rl.CloseWindow()

	number_font.load()
	defer number_font.unload()

	board := new_board_randomized(SETTINGS)

	hot_cell: HotPosition = nil

	for !rl.WindowShouldClose() {
		// Input
		mouse_pos := get_mouse_pos()
		new_hot_cell := get_hot_cell(board, mouse_pos)
		if new_hot_cell != hot_cell {
			log.debug("hot cell:", new_hot_cell)
			// Log numbers for the newly highlighted row and column.
			if hot, ok := new_hot_cell.?; ok {
				hot_row := row(board, hot[1])
				hot_col := column(board, hot[0])
				row_nums := get_numbers(hot_row)
				col_nums := get_numbers(hot_col)

				log.info("hot row nums:", row_nums)
				log.info("hot col nums:", col_nums)
				delete(hot_col)
			}
		}
		hot_cell = new_hot_cell

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		draw_board(board)

		if hot, ok := hot_cell.?; ok {
			draw_hot_cell_indicators(board, hot)
		}

		rl.EndDrawing()
	}

}
