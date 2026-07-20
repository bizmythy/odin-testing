package game

import ring "../ring"

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

active_state :: proc(board: Board) -> ^Board_State {
	assert(ring.len(board.state_queue) > 0, "Board has no states")
	assert(board.active_state_index >= 0, "Active board state index out of range")
	assert(
		board.active_state_index < ring.len(board.state_queue),
		"Active board state index out of range",
	)
	return ring.get_ptr(board.state_queue, board.active_state_index)
}

destroy_board_state :: proc(state: ^Board_State) {
	if len(state.cells) > 0 {
		delete(state.cells[0])
	}
	delete(state.cells)
	state^ = {}
}

clone_board_state :: proc(state: ^Board_State) -> Board_State {
	cell_count := 0
	for cells in state.cells {
		cell_count += len(cells)
	}

	buffer, buffer_err := make([]Cell, cell_count)
	if buffer_err != .None {
		panic("failed to clone board cells")
	}

	rows, rows_err := make([][]Cell, len(state.cells))
	if rows_err != .None {
		delete(buffer)
		panic("failed to clone board rows")
	}

	offset := 0
	for cells, row_index in state.cells {
		row_length := len(cells)
		rows[row_index] = buffer[offset:offset + row_length]
		copy(rows[row_index], cells)
		offset += row_length
	}
	return Board_State{cells = rows}
}

push_board_state :: proc(board: ^Board, state: Board_State) {
	// A new edit after an undo creates a new history branch.
	for index := board.active_state_index + 1; index < ring.len(board.state_queue); index += 1 {
		discarded := ring.get_ptr(board.state_queue, index)
		destroy_board_state(discarded)
	}
	ring.truncate(&board.state_queue, board.active_state_index + 1)

	evicted, did_evict := ring.push(&board.state_queue, state)
	if did_evict {
		destroy_board_state(&evicted)
	}
	board.active_state_index = ring.len(board.state_queue) - 1
}
