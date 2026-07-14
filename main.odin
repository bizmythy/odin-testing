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
	state:           CellState, // Active state of the cell.
	solution_filled: bool, // Does the solution have this as `Filled`?
}

Board :: struct {
	cells: [][]Cell, // Cells, by row then column.
}

new_board :: proc(size: u32) -> Board {
	buffer, err := make([]Cell, size*size)
	if err != .None {
		panic("failed to alloc board")
	}

	loc : u32 = 0
	for row in 0..<size {
		
	}
}

Square :: struct {
	corner:   Vec2,
	side_len: f32,
}

square_to_rec :: proc(s: Square) -> rl.Rectangle {
	return rl.Rectangle{x = s.corner[0], y = s.corner[1], width = s.side_len, height = s.side_len}
}

square_offset :: proc(s: Square, offset: f32) -> Square {
	assert((offset * -2) < s.side_len, "negative offset too large for given Square")

	off_vec := Vec2{offset, offset}
	return Square{corner = s.corner + off_vec, side_len = s.side_len + offset}
}

draw_cell :: proc(p: Position) {
	// CONSTS
	cell_size :: 50.0
	border_thickness :: 5.0
	border_color :: rl.Color{0, 0, 255, 255}

	
	corner := Vec2{cast(f32)p[0] * cell_size, cast(f32)p[1] * cell_size}
	s := Square{corner = corner, side_len = cell_size}
	
	border_square := square_offset(s, border_thickness)
	rl.DrawRectangleLinesEx(square_to_rec(border_square), border_thickness, border_color)
}

main :: proc() {
	board_size :: 30

	rl.InitWindow(1280, 720, "nonogramination")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({160, 200, 255, 255})

		for row in 0 ..< board_size {
			for column in 0 ..< board_size {
				draw_cell(Position{row, column})
			}
		}
	}

	rl.CloseWindow()
}
