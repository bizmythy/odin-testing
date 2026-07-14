package game

import rl "vendor:raylib"

// Location on grid, row then column.
Position :: [2]int

// 2D vector.
Vec2 :: rl.Vector2

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

Square :: struct {
	corner: Vec2,
	side_len: f32,
}

square_to_rec :: proc(s: Square) -> rl.Rectangle {
	return rl.Rectangle{
		x = s.corner[0],
		y = s.corner[1],
		width = s.side_len,
		height = s.side_len,
	}
}

square_offset :: proc(s: Square, offset: f32) -> Square {
	assert((offset * -2) < s.side_len, "negative offset too large for given Square")

	off_vec := Vec2{offset, offset}
	return Square{
		corner = s.corner - off_vec,
		side_len = s.side_len - offset,
	}
}

draw_cell :: proc(s: Square) {
	border_thickness :: 5.0
	border_color :: rl.Color{0, 0, 255, 255}
	rl.DrawRectangleLinesEx(square_to_rec(s), border_thickness, border_color)
}

draw_row_col :: proc(p: Position) {
	cell_size :: 50.0

	corner := Vec2{
		cast(f32)p[0] * cell_size,
		cast(f32)p[1] * cell_size,
	}
	draw_cell(Square{
		corner = corner,
		side_len = cell_size,
	})
}

main :: proc() {
	
	rl.InitWindow(1280, 720, "nonogramination")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		for row in 0..<30 {
			for column in 0..<30 {
				draw_row_col(Position{row, column})
			}
		}
	}

	rl.CloseWindow()
}
