package game

// Maximum number count permitted
MAX_NUMBERS :: 30

// Collection of constraint counts, displayed for row or column
Numbers :: [dynamic; MAX_NUMBERS]u32

get_numbers :: proc(cells: []Cell) -> (nums: Numbers) {
	working_count: u32 = 0
	for cell in cells {
		// if this is a real fill, inc and proceed
		if cell.solution_filled {
			working_count += 1
			continue
		}

		// if we weren't counting a section, proceed
		if working_count == 0 {continue}
		// negative edge: save the section we were counting and reset
		append(&nums, working_count)
		working_count = 0
	}
	// save any remaining count
	if working_count > 0 {
		append(&nums, working_count)
	}
	return
}
