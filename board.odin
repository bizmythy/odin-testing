package game

import "core:math/rand"

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
	size:  u32, // Size of board.
}

get_cell :: proc(b: Board, p: Position) -> Cell {
	return b.cells[p[0]][p[1]]
}

new_board :: proc(size: u32) -> Board {
	buffer, err := make([]Cell, size * size)
	if err != .None {
		panic("failed to alloc board")
	}

	rows, rows_err := make([][]Cell, size)
	if rows_err != .None {
		delete(buffer)
		panic("failed to alloc board rows")
	}

	for row in 0 ..< size {
		start := row * size
		rows[row] = buffer[start:start + size]
	}

	return Board{cells = rows, size = size}
}

new_board_randomized :: proc(size: u32) -> Board {
	board := new_board(size)

	for &row in board.cells {
		for &cell in row {
			// randomized cell state
			cell.state = rand.choice_enum(CellState)
			// random toggle between true and false
			cell.solution_filled = (rand.uint32_max(2) != 0)
		}
	}

	return board
}
