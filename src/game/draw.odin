package game

import rl "vendor:raylib"

BORDER_THICKNESS :: 5.0

Color :: rl.Color

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

position_square :: proc(board: Board, position: Position) -> Square {
	corner := board.corner + Vec2{cast(f32)position[0], cast(f32)position[1]} * board.cell_size
	return Square{corner = corner, side_len = board.cell_size}
}

border_square :: proc(square: Square) -> Square {
	// Center each border on the boundary
	return square_offset(square, BORDER_THICKNESS / 2)
}

draw_cell :: proc(board: Board, position: Position) {
	// Consts
	CROSS_THICKNESS :: 8.0
	MARKING_COLOR :: Color{155, 155, 155, 255}
	BORDER_COLOR :: Color{0, 0, 255, 255}

	// Get cell
	cell := get_cell(board, position)

	// Draw Border
	cell_square := position_square(board, position)
	rl.DrawRectangleLinesEx(
		square_to_rectangle(border_square(cell_square)),
		BORDER_THICKNESS,
		BORDER_COLOR,
	)

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
	board_size := size(board)
	for row in 0 ..< board_size {
		for column in 0 ..< board_size {
			position := Position{column, row}
			draw_cell(board, position)
		}
	}
}

draw_hot_cell_indicators :: proc(board: Board, hot_position: Position) {
	HOT_COLOR :: Color{255, 255, 0, 255}

	hot_border := border_square(position_square(board, hot_position))
	dims := dimensions(board)

	// vertical lines
	{
		// x coords of the two lines
		x_left := hot_border.corner[0]
		x_right := x_left + hot_border.side_len

		y_start := dims.corner[1]
		y_end := y_start + dims.side_len

		// left line
		rl.DrawLineEx(Vec2{x_left, y_start}, Vec2{x_left, y_end}, BORDER_THICKNESS, HOT_COLOR)
		// right line
		rl.DrawLineEx(Vec2{x_right, y_start}, Vec2{x_right, y_end}, BORDER_THICKNESS, HOT_COLOR)
	}

	// horizontal lines
	{
		// y coords of the two lines
		y_top := hot_border.corner[1]
		y_bottom := y_top + hot_border.side_len

		x_start := dims.corner[0]
		x_end := x_start + dims.side_len

		// top line
		rl.DrawLineEx(Vec2{x_start, y_top}, Vec2{x_end, y_top}, BORDER_THICKNESS, HOT_COLOR)
		// bottom line
		rl.DrawLineEx(Vec2{x_start, y_bottom}, Vec2{x_end, y_bottom}, BORDER_THICKNESS, HOT_COLOR)
	}
}
