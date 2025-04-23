const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

// TODO: replace this with actual unit testing
test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
