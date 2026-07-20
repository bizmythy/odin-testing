package game

import number_font "number_font"
import rl "vendor:raylib"

BORDER_THICKNESS :: 5.0
BORDER_COLOR :: Color{0, 0, 255, 255}
HOT_COLOR :: Color{255, 255, 0, 255}

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

draw_cell :: proc(board: Board, position: Position) {
	// Consts
	CROSS_THICKNESS :: 8.0
	MARKING_COLOR :: Color{155, 155, 155, 255}

	// Get cell
	cell := get_cell(board, position)
	cell_square := position_square(board, position)

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

draw_number :: proc(n: Number, settings: Number_Settings, position: Vec2, color: Color) {
	codepoints := format_number(n)
	rl.DrawTextCodepoints(
		number_font.FONT,
		&codepoints[0],
		len(codepoints),
		position,
		settings.font_size,
		settings.spacing,
		color,
	)
}

NUMBER_SPACING :: 5.0

draw_row_numbers :: proc(board: Board, settings: Number_Settings, row_index: u32, color: Color) {
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
		draw_number(number, settings, number_position, color)
	}
}

draw_column_numbers :: proc(board: Board, settings: Number_Settings, column_index: u32, color: Color) {
	column_cells := column(board, column_index)
	defer delete(column_cells)
	numbers := get_numbers(column_cells)

	// get center top point of box representing column
	column_center_x := board.cell_size * cast(f32)column_index + (board.cell_size / 2)
	column_center_top := board.corner + Vec2{column_center_x, 0}

	// shift left corner of number by distance to center
	number_position := column_center_top - Vec2{settings.size[0] / 2, 0}

	// offset each step by number height
	number_height := settings.size[1] + NUMBER_SPACING
	number_offset := Vec2{0, -number_height}

	#reverse for number in numbers {
		number_position += number_offset
		draw_number(number, settings, number_position, color)
	}
}

get_number_area_size :: proc(board: Board, settings: Number_Settings) -> Vec2 {
	max_row_numbers := 0
	max_column_numbers := 0
	board_size := size(board)

	for row_index in 0 ..< board_size {
		numbers := get_numbers(row(board, row_index))
		max_row_numbers = max(max_row_numbers, len(numbers))
	}
	for column_index in 0 ..< board_size {
		column_cells := column(board, column_index)
		numbers := get_numbers(column_cells)
		max_column_numbers = max(max_column_numbers, len(numbers))
		delete(column_cells)
	}

	return Vec2 {
		cast(f32)max_row_numbers * (settings.size[0] + NUMBER_SPACING),
		cast(f32)max_column_numbers * (settings.size[1] + NUMBER_SPACING),
	}
}

is_hot_row :: proc(hot_position: HotPosition, row_index: u32) -> bool {
	if hot, ok := hot_position.?; ok {
		return row_index == hot[1]
	}
	return false
}

is_hot_column :: proc(hot_position: HotPosition, column_index: u32) -> bool {
	if hot, ok := hot_position.?; ok {
		return column_index == hot[0]
	}
	return false
}

is_hot_row_border :: proc(hot_position: HotPosition, border_index: u32) -> bool {
	if hot, ok := hot_position.?; ok {
		return border_index == hot[1] || border_index == hot[1] + 1
	}
	return false
}

is_hot_column_border :: proc(hot_position: HotPosition, border_index: u32) -> bool {
	if hot, ok := hot_position.?; ok {
		return border_index == hot[0] || border_index == hot[0] + 1
	}
	return false
}

draw_board_borders :: proc(board: Board, number_area: Vec2, hot_position: HotPosition) {
	board_side_len := board.cell_size * cast(f32)size(board)
	board_size := size(board)

	for column_border in 0 ..= board_size {
		x := board.corner[0] + board.cell_size * cast(f32)column_border
		color := HOT_COLOR if is_hot_column_border(hot_position, column_border) else BORDER_COLOR
		rl.DrawRectangleRec(
			rl.Rectangle {
				x = x - BORDER_THICKNESS / 2,
				y = board.corner[1] - number_area[1] - BORDER_THICKNESS / 2,
				width = BORDER_THICKNESS,
				height = board_side_len + number_area[1] + BORDER_THICKNESS,
			},
			color,
		)
	}

	for row_border in 0 ..= board_size {
		y := board.corner[1] + board.cell_size * cast(f32)row_border
		color := HOT_COLOR if is_hot_row_border(hot_position, row_border) else BORDER_COLOR
		rl.DrawRectangleRec(
			rl.Rectangle {
				x = board.corner[0] - number_area[0] - BORDER_THICKNESS / 2,
				y = y - BORDER_THICKNESS / 2,
				width = board_side_len + number_area[0] + BORDER_THICKNESS,
				height = BORDER_THICKNESS,
			},
			color,
		)
	}
}

draw_board :: proc(board: Board, hot_position: HotPosition) {
	settings := get_number_settings(board)
	number_area := get_number_area_size(board, settings)
	board_size := size(board)

	for row_index in 0 ..< board_size {
		for column_index in 0 ..< board_size {
			position := Position{column_index, row_index}
			draw_cell(board, position)
		}
	}

	for column_index in 0 ..< board_size {
		color := HOT_COLOR if is_hot_column(hot_position, column_index) else BORDER_COLOR
		draw_column_numbers(board, settings, column_index, color)
	}
	for row_index in 0 ..< board_size {
		color := HOT_COLOR if is_hot_row(hot_position, row_index) else BORDER_COLOR
		draw_row_numbers(board, settings, row_index, color)
	}

	draw_board_borders(board, number_area, hot_position)
}
