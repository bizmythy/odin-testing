package game

import rl "vendor:raylib"

get_hot_cell :: proc(board: Board) -> Maybe(Position) {
	mouse_coord := rl.GetMousePosition()

	mouse_rel := mouse_coord - board.corner
	position_approx := mouse_rel / board.cell_size

	// Check within bounds
	cells_bound := cast(f32)size(board)
	if position_approx[0] < 0 || position_approx[0] >= cells_bound {
		// X coord OOB
		return nil
	}
	if position_approx[1] < 0 || position_approx[1] >= cells_bound {
		// Y coord OOB
		return nil
	}

	// Round down to uint position
	return Position{
		cast(u32)position_approx[0],
		cast(u32)position_approx[1],
	}
}

