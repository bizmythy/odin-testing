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
	corner:    Vec2,
	cell_size: f32,
	cells:     [][]Cell, // Cells, by row then column.
	size:      u32, // Size of board.
}

get_cell :: proc(board: Board, position: Position) -> ^Cell {
	return &board.cells[position[0]][position[1]]
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

	return Board{corner = corner, cell_size = cell_size, cells = rows, size = count}
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
