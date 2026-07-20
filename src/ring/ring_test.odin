package ring

import "core:testing"

@(test)
push_preserves_logical_order :: proc(t: ^testing.T) {
	buffer: Ring_Buffer(int)
	err := init(&buffer, 3)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer destroy(&buffer)

	push(&buffer, 10)
	push(&buffer, 20)
	push(&buffer, 30)

	testing.expect_value(t, len(buffer), 3)
	testing.expect_value(t, cap(buffer), 3)
	testing.expect_value(t, is_full(buffer), true)
	testing.expect_value(t, get(buffer, 0), 10)
	testing.expect_value(t, get(buffer, 1), 20)
	testing.expect_value(t, get(buffer, 2), 30)
}

@(test)
push_overwrites_oldest_when_full :: proc(t: ^testing.T) {
	buffer: Ring_Buffer(int)
	err := init(&buffer, 3)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer destroy(&buffer)

	push(&buffer, 1)
	push(&buffer, 2)
	push(&buffer, 3)

	evicted, did_evict := push(&buffer, 4)
	testing.expect_value(t, did_evict, true)
	testing.expect_value(t, evicted, 1)
	testing.expect_value(t, len(buffer), 3)
	testing.expect_value(t, get(buffer, 0), 2)
	testing.expect_value(t, get(buffer, 1), 3)
	testing.expect_value(t, get(buffer, 2), 4)

	evicted, did_evict = push(&buffer, 5)
	testing.expect_value(t, did_evict, true)
	testing.expect_value(t, evicted, 2)
	testing.expect_value(t, get(buffer, 0), 3)
	testing.expect_value(t, get(buffer, 1), 4)
	testing.expect_value(t, get(buffer, 2), 5)
}

@(test)
push_before_full_does_not_evict :: proc(t: ^testing.T) {
	buffer: Ring_Buffer(string)
	err := init(&buffer, 2)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer destroy(&buffer)

	_, did_evict := push(&buffer, "first")
	testing.expect_value(t, did_evict, false)
	testing.expect_value(t, len(buffer), 1)
	testing.expect_value(t, is_empty(buffer), false)
}

@(test)
get_ptr_updates_wrapped_entry :: proc(t: ^testing.T) {
	buffer: Ring_Buffer(int)
	err := init(&buffer, 2)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer destroy(&buffer)

	push(&buffer, 1)
	push(&buffer, 2)
	push(&buffer, 3)
	get_ptr(buffer, 1)^ = 30

	testing.expect_value(t, get(buffer, 0), 2)
	testing.expect_value(t, get(buffer, 1), 30)
}

@(test)
clear_reuses_capacity :: proc(t: ^testing.T) {
	buffer: Ring_Buffer(int)
	err := init(&buffer, 2)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer destroy(&buffer)

	push(&buffer, 1)
	push(&buffer, 2)
	clear(&buffer)

	testing.expect_value(t, len(buffer), 0)
	testing.expect_value(t, cap(buffer), 2)
	testing.expect_value(t, is_empty(buffer), true)

	_, did_evict := push(&buffer, 3)
	testing.expect_value(t, did_evict, false)
	testing.expect_value(t, get(buffer, 0), 3)
}
