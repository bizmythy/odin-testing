// Package ring provides a fixed-capacity ring buffer.
package ring

import "base:builtin"
import "base:runtime"

Ring_Buffer :: struct($T: typeid) {
	data:      []T,
	start:     int,
	count:     int,
	allocator: runtime.Allocator,
}

// init allocates the buffer's entire backing store. It does not allocate again
// until the buffer is destroyed and reinitialized.
init :: proc(
	buffer: ^$R/Ring_Buffer($T),
	capacity: int,
	allocator := context.allocator,
) -> runtime.Allocator_Error {
	assert(capacity > 0, "Ring buffer capacity must be greater than zero")

	data, err := make([]T, capacity, allocator)
	if err != .None {
		return err
	}

	buffer^ = R {
		data      = data,
		allocator = allocator,
	}
	return .None
}

// destroy releases the fixed backing allocation.
destroy :: proc(buffer: ^$R/Ring_Buffer($T)) {
	delete(buffer.data, buffer.allocator)
	buffer^ = {}
}

len :: proc(buffer: $R/Ring_Buffer($T)) -> int {
	return buffer.count
}

cap :: proc(buffer: $R/Ring_Buffer($T)) -> int {
	return builtin.len(buffer.data)
}

is_empty :: proc(buffer: $R/Ring_Buffer($T)) -> bool {
	return buffer.count == 0
}

is_full :: proc(buffer: $R/Ring_Buffer($T)) -> bool {
	return buffer.count == builtin.len(buffer.data)
}

// get_ptr returns an item by logical index, where index zero is the oldest
// item and len(buffer)-1 is the newest.
get_ptr :: proc(buffer: $R/Ring_Buffer($T), index: int) -> ^T {
	assert(index >= 0 && index < buffer.count, "Ring buffer index out of range")
	physical_index := (buffer.start + index) % builtin.len(buffer.data)
	return &buffer.data[physical_index]
}

get :: proc(buffer: $R/Ring_Buffer($T), index: int) -> T {
	return get_ptr(buffer, index)^
}

// push adds an item as the newest entry. When the buffer is full, it replaces
// and returns the oldest entry without allocating.
push :: proc(buffer: ^$R/Ring_Buffer($T), value: T) -> (evicted: T, did_evict: bool) {
	assert(builtin.len(buffer.data) > 0, "Ring buffer is not initialized")

	write_index := (buffer.start + buffer.count) % builtin.len(buffer.data)
	if is_full(buffer^) {
		write_index = buffer.start
		evicted = buffer.data[write_index]
		did_evict = true
		buffer.start = (buffer.start + 1) % builtin.len(buffer.data)
	} else {
		buffer.count += 1
	}

	buffer.data[write_index] = value
	return
}

// truncate removes entries from the newest end until new_length remains.
// Removed values are zeroed but are not otherwise destroyed.
truncate :: proc(buffer: ^$R/Ring_Buffer($T), new_length: int) {
	assert(new_length >= 0 && new_length <= buffer.count, "Invalid ring buffer length")
	for index := new_length; index < buffer.count; index += 1 {
		physical_index := (buffer.start + index) % builtin.len(buffer.data)
		buffer.data[physical_index] = {}
	}
	buffer.count = new_length
	if new_length == 0 {
		buffer.start = 0
	}
}

// clear removes all entries while retaining the fixed backing allocation.
clear :: proc(buffer: ^$R/Ring_Buffer($T)) {
	truncate(buffer, 0)
}
