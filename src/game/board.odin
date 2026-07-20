package game

import "core:math/rand"

Cell_State :: enum u8 {
	Filled,
	Crossed,
	Empty,
}

Cell :: struct {
	state:           Cell_State, // Active state of the cell.
	solution_filled: bool, // Does the solution have this as `Filled`?
}

Board :: struct {
	corner:    Vec2, // Top-left coordinate of board.
	cell_size: f32, // Size of one side of one cell.
	cells:     [][]Cell, // Cells, by row then column.
}

// Get cell count side length of Board
size :: proc(board: Board) -> u32 {
	rows := len(board.cells)
	assert(rows == len(board.cells[0]), "rows and columns not even for Board, not supported")
	return cast(u32)rows
}

// Get Square defining dimensions of overall Board
dimensions :: proc(board: Board) -> Square {
	side_len := board.cell_size * cast(f32)size(board)
	return Square{corner = board.corner, side_len = side_len}
}

// Get cell at specific position
get_cell :: proc(board: Board, position: Position) -> ^Cell {
	board_size := size(board)
	assert(position[0] < board_size, "Position X value out of range")
	assert(position[1] < board_size, "Position Y value out of range")
	return &board.cells[position[1]][position[0]]
}

// Get a copy of the cells for a certain column index.
// The caller owns the returned slice and must delete it.
column :: proc(board: Board, column_index: u32) -> []Cell {
	board_size := size(board)
	assert(column_index < board_size, "Column index out of range")

	cells, err := make([]Cell, board_size)
	if err != .None {
		panic("failed to alloc column")
	}
	for row_index in 0 ..< board_size {
		cells[row_index] = board.cells[row_index][column_index]
	}
	return cells
}

// Get the cells for a certain row index.
row :: proc(board: Board, row_index: u32) -> []Cell {
	assert(row_index < size(board), "Row index out of range")
	return board.cells[row_index]
}

Board_Settings :: struct {
	count:     u32,
	corner:    Vec2,
	cell_size: f32,
}

new_board :: proc(s: Board_Settings) -> Board {
	buffer, err := make([]Cell, s.count * s.count)
	if err != .None {
		panic("failed to alloc board")
	}

	rows, rows_err := make([][]Cell, s.count)
	if rows_err != .None {
		delete(buffer)
		panic("failed to alloc board rows")
	}

	for row in 0 ..< s.count {
		start := row * s.count
		rows[row] = buffer[start:start + s.count]
	}

	return Board{corner = s.corner, cell_size = s.cell_size, cells = rows}
}

new_board_randomized :: proc(s: Board_Settings) -> Board {
	board := new_board(s)

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
