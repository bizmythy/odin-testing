package game

import rl "vendor:raylib"

Square :: struct {
	corner:   Vec2,
	side_len: f32,
}

square_to_rectangle :: proc(square: Square) -> rl.Rectangle {
	return rl.Rectangle {
		x = square.corner[0],
		y = square.corner[1],
		width = square.side_len,
		height = square.side_len,
	}
}

square_offset :: proc(square: Square, offset: f32) -> Square {
	assert((offset * -2) < square.side_len, "negative offset too large for given Square")

	offset_vector := Vec2{offset, offset}
	return Square{corner = square.corner + offset_vector, side_len = square.side_len + offset}
}

draw_cell :: proc(cell: Cell, position: Position) {
	CELL_SIZE :: 50.0
	BORDER_THICKNESS :: 5.0
	BORDER_COLOR :: rl.Color{0, 0, 255, 255}

	corner := Vec2{cast(f32)position[0] * CELL_SIZE, cast(f32)position[1] * CELL_SIZE}
	square := Square {
		corner   = corner,
		side_len = CELL_SIZE,
	}

	border_square := square_offset(square, BORDER_THICKNESS)
	rl.DrawRectangleLinesEx(square_to_rectangle(border_square), BORDER_THICKNESS, BORDER_COLOR)
}

draw_board :: proc(board: Board) {
	for row in 0 ..< board.size {
		for column in 0 ..< board.size {
			position := Position{row, column}
			cell := get_cell(board, position)
			draw_cell(cell, position)
		}
	}
}
