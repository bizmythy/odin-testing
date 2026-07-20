package game

import ring "../ring"
import "core:testing"

test_board :: proc(history_capacity: int) -> Board {
	return new_board(
		Board_Settings{count = 1, history_capacity = history_capacity, corner = {}, cell_size = 1},
	)
}

push_cell_state :: proc(board: ^Board, cell_state: Cell_State) {
	state := clone_board_state(active_state(board^))
	state.cells[0][0].state = cell_state
	push_board_state(board, state)
}

@(test)
board_history_keeps_independent_states :: proc(t: ^testing.T) {
	board := test_board(3)
	defer destroy_board(&board)

	push_cell_state(&board, .Crossed)
	push_cell_state(&board, .Empty)

	testing.expect_value(t, get_cell(board, {0, 0}).state, Cell_State.Empty)
	board.active_state_index -= 1
	testing.expect_value(t, get_cell(board, {0, 0}).state, Cell_State.Crossed)
	board.active_state_index -= 1
	testing.expect_value(t, get_cell(board, {0, 0}).state, Cell_State.Filled)
}

@(test)
new_state_after_undo_discards_redo_history :: proc(t: ^testing.T) {
	board := test_board(4)
	defer destroy_board(&board)

	push_cell_state(&board, .Crossed)
	push_cell_state(&board, .Empty)
	board.active_state_index = 0
	push_cell_state(&board, .Empty)

	testing.expect_value(t, ring.len(board.state_queue), 2)
	testing.expect_value(t, board.active_state_index, 1)
	testing.expect_value(t, get_cell(board, {0, 0}).state, Cell_State.Empty)
}

@(test)
board_history_evicts_oldest_state_at_capacity :: proc(t: ^testing.T) {
	board := test_board(2)
	defer destroy_board(&board)

	push_cell_state(&board, .Crossed)
	push_cell_state(&board, .Empty)

	testing.expect_value(t, ring.len(board.state_queue), 2)
	testing.expect_value(t, board.active_state_index, 1)
	board.active_state_index = 0
	testing.expect_value(t, get_cell(board, {0, 0}).state, Cell_State.Crossed)
}
