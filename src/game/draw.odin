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
	return Square{corner = square.corner - offset_vector, side_len = square.side_len + 2 * offset}
}

Square_Corners :: struct {
	top_left:     Vec2,
	top_right:    Vec2,
	bottom_left:  Vec2,
	bottom_right: Vec2,
}

square_corners :: proc(square: Square) -> (points: Square_Corners) {
	right_offset := Vec2{square.side_len, 0}
	down_offset := Vec2{0, square.side_len}

	points.top_left = square.corner
	points.top_right = points.top_left + right_offset
	points.bottom_left = points.top_left + down_offset
	points.bottom_right = points.top_right + down_offset
	return
}

draw_cell :: proc(cell: Cell, position: Position) {
	// Consts
	CELL_SIZE :: 50.0
	BORDER_THICKNESS :: 5.0
	CROSS_THICKNESS :: 8.0
	BORDER_COLOR :: rl.Color{0, 0, 255, 255}
	MARKING_COLOR :: rl.Color{155, 155, 155, 255}

	// Draw Border
	corner := Vec2{cast(f32)position[0] * CELL_SIZE, cast(f32)position[1] * CELL_SIZE}
	cell_square := Square {
		corner   = corner,
		side_len = CELL_SIZE,
	}
	border_square := square_offset(cell_square, BORDER_THICKNESS / 2) // Center each border on the cell boundary
	rl.DrawRectangleLinesEx(square_to_rectangle(border_square), BORDER_THICKNESS, BORDER_COLOR)

	// Draw inside cell based on state
	switch cell.state {
	case .Wall:
		// Fill with wall color
		rl.DrawRectangleRec(square_to_rectangle(cell_square), BORDER_COLOR)
	case .Filled:
		// Mostly fill with filled color
		filled_square := square_offset(cell_square, -BORDER_THICKNESS)
		rl.DrawRectangleRec(square_to_rectangle(filled_square), MARKING_COLOR)
	case .Crossed:
		// Draw cross
		circumsquare := square_offset(cell_square, -CROSS_THICKNESS)
		corners := square_corners(circumsquare)
		rl.DrawLineEx(corners.top_left, corners.bottom_right, CROSS_THICKNESS, MARKING_COLOR)
		rl.DrawLineEx(corners.top_right, corners.bottom_left, CROSS_THICKNESS, MARKING_COLOR)
	case .Empty: // Do nothing, is empty
	}
}

draw_board :: proc(board: Board) {
	OFFSET :: Position{1, 1}
	for row in 0 ..< board.size {
		for column in 0 ..< board.size {
			position := Position{row, column}
			cell := get_cell(board, position)
			draw_cell(cell, position + OFFSET)
		}
	}
}
