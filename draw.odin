package game

import rl "vendor:raylib"

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

draw_cell :: proc(c: Cell, p: Position) {
	// CONSTS
	cell_size :: 50.0
	border_thickness :: 5.0
	border_color :: rl.Color{0, 0, 255, 255}


	corner := Vec2{cast(f32)p[0] * cell_size, cast(f32)p[1] * cell_size}
	s := Square {
		corner   = corner,
		side_len = cell_size,
	}

	border_square := square_offset(s, border_thickness)
	rl.DrawRectangleLinesEx(square_to_rec(border_square), border_thickness, border_color)
}

draw_board :: proc(b: Board) {
	for row in 0 ..< b.size {
		for column in 0 ..< b.size {
			position := Position{row, column}
			cell := get_cell(b, position)
			draw_cell(cell, position)
		}
	}
}
