package game

import ring "../ring"
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

Board_State :: struct {
	cells: [][]Cell, // Cells, by row then column.
}

Board :: struct {
	state_queue:        ring.Ring_Buffer(Board_State),
	active_state_index: int,
	corner:             Vec2, // Top-left coordinate of board.
	cell_size:          f32, // Size of one side of one cell.
}

active_state :: proc(board: Board) -> ^Board_State {
	assert(ring.len(board.state_queue) > 0, "Board has no states")
	assert(board.active_state_index >= 0, "Active board state index out of range")
	assert(
		board.active_state_index < ring.len(board.state_queue),
		"Active board state index out of range",
	)
	return ring.get_ptr(board.state_queue, board.active_state_index)
}

// Get cell count side length of Board
size :: proc(board: Board) -> u32 {
	state := active_state(board)
	rows := len(state.cells)
	assert(rows == len(state.cells[0]), "rows and columns not even for Board, not supported")
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
	return &active_state(board).cells[position[1]][position[0]]
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
	state := active_state(board)
	for row_index in 0 ..< board_size {
		cells[row_index] = state.cells[row_index][column_index]
	}
	return cells
}

// Get the cells for a certain row index.
row :: proc(board: Board, row_index: u32) -> []Cell {
	assert(row_index < size(board), "Row index out of range")
	return active_state(board).cells[row_index]
}

Board_Settings :: struct {
	count:            u32,
	history_capacity: int,
	corner:           Vec2,
	cell_size:        f32,
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

	state_queue: ring.Ring_Buffer(Board_State)
	queue_err := ring.init(&state_queue, s.history_capacity)
	if queue_err != .None {
		delete(rows)
		delete(buffer)
		panic("failed to alloc board state queue")
	}
	ring.push(&state_queue, Board_State{cells = rows})

	return Board {
		state_queue = state_queue,
		active_state_index = 0,
		corner = s.corner,
		cell_size = s.cell_size,
	}
}

destroy_board :: proc(board: ^Board) {
	for index in 0 ..< ring.len(board.state_queue) {
		state := ring.get_ptr(board.state_queue, index)
		if len(state.cells) > 0 {
			delete(state.cells[0])
		}
		delete(state.cells)
	}
	ring.destroy(&board.state_queue)
	board^ = {}
}

new_board_randomized :: proc(s: Board_Settings) -> Board {
	board := new_board(s)

	state := active_state(board)
	for &row in state.cells {
		for &cell in row {
			// randomized cell state
			cell.state = rand.choice_enum(Cell_State)
			// random toggle between true and false
			cell.solution_filled = (rand.uint32_max(2) != 0)
		}
	}

	return board
}
