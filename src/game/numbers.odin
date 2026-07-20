package game

// Can only represent 2 digits or less
LARGEST_NUMBER :: 99

Number :: distinct u32

new_number :: proc(n: u32) -> Number {
	assert(n < LARGEST_NUMBER, "Number will exceed maximum displayable number")
	return cast(Number)min(n, LARGEST_NUMBER)
}

Number_Codepoints :: [2]rune

format_number :: proc(n: Number) -> Number_Codepoints {
	assert(n <= LARGEST_NUMBER, "Number will exceed maximum displayable number")
	codepoints: Number_Codepoints
	// tens place
	codepoints[1] = cast(rune)('0' + (n / 10))
	// ones place
	codepoints[0] = cast(rune)('0' + (n % 10))
	return codepoints
}

// Maximum number count permitted
MAX_NUMBERS :: 30

// Collection of constraint counts, displayed for row or column
Numbers :: [dynamic; MAX_NUMBERS]Number

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
		append(&nums, new_number(working_count))
		working_count = 0
	}
	// save any remaining count
	if working_count > 0 {
		append(&nums, new_number(working_count))
	}
	return
}
