package screenshot

import "core:log"
import "core:os"
import rl "vendor:raylib"

SCREENSHOT_DIRECTORY :: "screenshots"
SCREENSHOT_PATH :: SCREENSHOT_DIRECTORY + "/game.png"

// run saves the current frame when S is pressed.
run :: proc() {
	if !rl.IsKeyPressed(.S) {
		return
	}

	if !os.exists(SCREENSHOT_DIRECTORY) {
		if err := os.make_directory_all(SCREENSHOT_DIRECTORY); err != nil {
			log.errorf("Could not create screenshot directory: %v", err)
			return
		}
	}

	rl.TakeScreenshot(SCREENSHOT_PATH)
}
