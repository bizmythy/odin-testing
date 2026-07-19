package game

import "core:math/rand"

Cell_State :: enum u8 {
	Wall,
	Filled,
	Crossed,
	Empty,
}

Cell :: struct {
	state:           Cell_State, // Active state of the cell.
	solution_filled: bool, // Does the solution have this as `Filled`?
}

Board :: struct {
	top_left:  Vec2, // Top-left coordinate of board.
	cell_size: f32, // Size of one side of one cell.
	cells:     [][]Cell, // Cells, by row then column.
}

size :: proc(board: Board) -> u32 {
	rows := len(board.cells)
	assert(rows == len(board.cells[0]), "rows and columns not even for Board, not supported")
	return cast(u32)rows
}

dimensions :: proc(board: Board) -> Vec2 {
	side_len := board.cell_size * cast(f32)size(board)
	return Vec2{side_len, side_len}
}

get_cell :: proc(board: Board, position: Position) -> ^Cell {
	return &board.cells[position[0]][position[1]]
}

get_position :: proc(board: Board, location: Vec2) -> Maybe(Position) {
	board_location := location - board.top_left

	unvalidated_position := board_location / board.cell_size
	// if
	return nil
}

new_board :: proc(count: u32, corner: Vec2, cell_size: f32) -> Board {
	buffer, err := make([]Cell, count * count)
	if err != .None {
		panic("failed to alloc board")
	}

	rows, rows_err := make([][]Cell, count)
	if rows_err != .None {
		delete(buffer)
		panic("failed to alloc board rows")
	}

	for row in 0 ..< count {
		start := row * count
		rows[row] = buffer[start:start + count]
	}

	return Board{top_left = corner, cell_size = cell_size, cells = rows}
}

new_board_randomized :: proc(count: u32) -> Board {
	CORNER :: Vec2{30, 30}
	CELL_SIZE :: 50.0

	board := new_board(count, CORNER, CELL_SIZE)

	for &row in board.cells {
		for &cell in row {
			// randomized cell state
			cell.state = rand.choice_enum(Cell_State)
			// random toggle between true and false
			cell.solution_filled = (rand.uint32_max(2) != 0)
		}
	}

	return board
}
