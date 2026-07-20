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

Number_Settings :: struct {
	font_size: f32, // Font size px
	spacing:   f32, // Spacing between digits
	size:      Vec2, // Measured size of two digit number
}

get_number_settings :: proc(board: Board) -> (settings: Number_Settings) {
	FONT_SIZE_RATIO :: 0.6
	FONT_SPACING_RATIO :: 0.1

	settings.font_size = board.cell_size * FONT_SIZE_RATIO
	settings.spacing = board.cell_size * FONT_SPACING_RATIO

	// Use test number, monospace has same size
	codepoints := format_number(new_number(88))
	// Measure and store the size all numbers are expected to be
	settings.size = rl.MeasureTextCodepoints(
		number_font.FONT,
		cast([^]i32)&codepoints[0],
		len(codepoints),
		settings.font_size,
		settings.spacing,
	)

	return
}

draw_number :: proc(n: Number, settings: Number_Settings, position: Vec2) {
	codepoints := format_number(n)
	rl.DrawTextCodepoints(
		number_font.FONT,
		&codepoints[0],
		len(codepoints),
		position,
		settings.font_size,
		settings.spacing,
		BORDER_COLOR,
	)
}

NUMBER_SPACING :: 5.0

draw_row_numbers :: proc(board: Board, settings: Number_Settings, row_index: u32) {
	row_cells := row(board, row_index)
	numbers := get_numbers(row_cells)

	// get center left point of box representing row
	row_center_y := board.cell_size * cast(f32)row_index + (board.cell_size / 2)
	row_center_left := board.corner + Vec2{0, row_center_y}

	// shift up corner of number by distance to center
	number_position := row_center_left - Vec2{0, settings.size[1] / 2}

	// offset each step by number width
	number_width := settings.size[0] + NUMBER_SPACING
	number_offset := Vec2{-number_width, 0}

	#reverse for number in numbers {
		number_position += number_offset
		draw_number(number, settings, number_position)
	}
}

draw_board :: proc(board: Board) {
	settings := get_number_settings(board)
	// first_number := new_number(46)
	// draw_number(first_number, settings, Vec2{30, 5})
	board_size := size(board)
	for row in 0 ..< board_size {
		draw_row_numbers(board, settings, row)
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
