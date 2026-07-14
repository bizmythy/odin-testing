package game

import rl "vendor:raylib"

// Location on grid, row then column.
Position :: [2]u32

CellState :: enum u8 {
	Wall,
	Filled,
	Crossed,
	Empty,
}

Cell :: struct {
	state: CellState, // Active state of the cell.
	solution_filled: bool, // Does the solution have this as `Filled`?
}

Board :: struct {
	cells: [][]Cell, // Cells, by row then column.
}

main :: proc() {
	rl.InitWindow(1280, 720, "nonogramination")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
