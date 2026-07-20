package game

import "core:testing"

test_cells :: proc(filled: []bool) -> []Cell {
	cells, err := make([]Cell, len(filled))
	assert(err == .None, "failed to allocate test cells")
	for is_filled, index in filled {
		cells[index].solution_filled = is_filled
	}
	return cells
}

expect_numbers :: proc(t: ^testing.T, filled: []bool, expected: []u32) {
	cells := test_cells(filled)
	defer delete(cells)

	actual := get_numbers(cells)
	if !testing.expect_value(t, len(actual), len(expected)) {
		return
	}
	for val, index in expected {
		testing.expect_value(t, actual[index], new_number(val))
	}
}

@(test)
get_numbers_empty_and_unfilled :: proc(t: ^testing.T) {
	empty := [0]bool{}
	no_numbers := [0]u32{}
	expect_numbers(t, empty[:], no_numbers[:])

	filled := [4]bool{false, false, false, false}
	expect_numbers(t, filled[:], no_numbers[:])
}

@(test)
get_numbers_single_run :: proc(t: ^testing.T) {
	filled := [5]bool{false, true, true, true, false}
	expected := [1]u32{3}
	expect_numbers(t, filled[:], expected[:])
}

@(test)
get_numbers_multiple_runs_including_edges :: proc(t: ^testing.T) {
	filled := [10]bool{true, true, false, true, false, false, true, true, true, true}
	expected := [3]u32{2, 1, 4}
	expect_numbers(t, filled[:], expected[:])
}

@(test)
get_numbers_all_filled :: proc(t: ^testing.T) {
	filled := [4]bool{true, true, true, true}
	expected := [1]u32{4}
	expect_numbers(t, filled[:], expected[:])
}

@(test)
format_number_two_digits :: proc(t: ^testing.T) {
	expected := [2]rune{'5', '3'}
	testing.expect_value(t, format_number(new_number(53)), expected)
}
