package game

import rl "vendor:raylib"

get_mouse_pos :: proc() -> Vec2 {
	rl.SetMouseScale(1, 1)
	mouse := rl.GetMousePosition()

	// DEBUG: draw circle at mouse pos
	rl.DrawCircleV(mouse, 5.0, rl.Color{0, 0, 0, 255})

	return mouse
}

HotCell :: Maybe(Position)

get_hot_cell :: proc(board: Board, global_coord: Vec2) -> HotCell {
	mouse_rel := global_coord - board.corner
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

	return Position{cast(u32)position_approx[0], cast(u32)position_approx[1]}
}
