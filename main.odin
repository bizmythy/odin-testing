package game

import rl "vendor:raylib"

Board :: struct {
	
}

main :: proc() {
	rl.InitWindow(1280, 720, "nonogramination")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
