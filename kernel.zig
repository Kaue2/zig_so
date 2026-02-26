const std = @import("std");

const size_t = u32;

extern var __bss: [0]u8;
extern var __bss_end: [0]u8;
extern var __stack_top: [0]u8;

fn memset(buf: *anyopaque, c: u8, n: size_t) *anyopaque {
    var p: [*]u8 = @ptrCast(buf);
    var i: size_t = 0;
    while (i < n) : (i += 1) {
        p[i] = c;
    }
    return buf;
}

test "memset fills a buffer" {
    // setup buffer
    var buffer: [5]u8 = [_]u8{ 0, 0, 0, 0, 0 };

    _ = memset(&buffer, 0, 3);

    try std.testing.expectEqual(buffer[0], 0);
    try std.testing.expectEqual(buffer[1], 0);
    try std.testing.expectEqual(buffer[2], 0);

    try std.testing.expectEqualSlices(u8, &[_]u8{ 'A', 'A', 'A', 0, 0 }, &buffer);
}
