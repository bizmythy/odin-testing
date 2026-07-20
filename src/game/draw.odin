package game

import number_font "number_font"
import rl "vendor:raylib"

BORDER_THICKNESS :: 5.0
BORDER_COLOR :: Color{0, 0, 255, 255}

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

	// DEBUG: draw a circle at the center to show the solution
	if cell.solution_filled {
		half_side := cell_square.side_len / 2
		center_point := cell_square.corner + Vec2{half_side, half_side}
		rl.DrawCircleV(center_point, 10, BORDER_COLOR)
	}
}

draw_number :: proc(n: Number, position: Vec2) {
	codepoints := format_number(n)
	rl.DrawTextCodepoints(
		number_font.FONT,
		&codepoints[0],
		len(codepoints),
		position,
		30, // TODO: determine based on board size etc.
		5, // TODO: check what this does
		BORDER_COLOR,
	)
}

draw_row_numbers :: proc(board: Board, row_index: u32) {

}

draw_board :: proc(board: Board) {
	draw_number(new_number(46), Vec2{30, 5})
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

	hot_square := position_square(board, hot_position)
	board_border := border_square(dimensions(board))

	// vertical lines
	{
		x_left := hot_square.corner[0]
		x_right := x_left + hot_square.side_len
		x_coords := [2]f32{x_left, x_right}

		for x in x_coords {
			rl.DrawRectangleRec(
				rl.Rectangle {
					x = x - BORDER_THICKNESS / 2,
					y = board_border.corner[1],
					width = BORDER_THICKNESS,
					height = board_border.side_len,
				},
				HOT_COLOR,
			)
		}
	}

	// horizontal lines
	{
		y_top := hot_square.corner[1]
		y_bottom := y_top + hot_square.side_len
		y_coords := [2]f32{y_top, y_bottom}

		for y in y_coords {
			rl.DrawRectangleRec(
				rl.Rectangle {
					x = board_border.corner[0],
					y = y - BORDER_THICKNESS / 2,
					width = board_border.side_len,
					height = BORDER_THICKNESS,
				},
				HOT_COLOR,
			)
		}
	}
}
