const std = @import("std");

const size_t = u32;

extern var __bss: [0]u8;
extern var __bss_end: [0]u8;
extern var __stack_top: [0]u8;

fn memset(buf: *anyopaque, c: c_char, n: usize) *anyopaque {
    var p: [*]u8 = @ptrCast(buf);
    const value: u8 = @intCast(c);
    var i: size_t = 0;

    while (i < n) : (i += 1) {
        p[i] = value;
    }

    return buf;
}

export fn kernel_main() void {
    _ = memset(&__bss, 0, @intFromPtr(&__bss_end) - @intFromPtr(&__bss));

    while (true) {}
}

export fn boot() linksection(".text.boot") callconv(.naked) void {
    asm volatile (
        \\mv sp, %[stack_top]
        \\j kernel_main
        :
        : [stack_top] "r" (&__stack_top),
    );
}

test "memset fills a buffer" {
    // setup buffer
    var buffer: [5]u8 = [_]u8{ 'A', 'A', 'A', 'A', 'A' };

    _ = memset(&buffer, 0, 3);

    try std.testing.expectEqual(buffer[0], 0);
    try std.testing.expectEqual(buffer[1], 0);
    try std.testing.expectEqual(buffer[2], 0);

    try std.testing.expectEqualSlices(u8, &[_]u8{ 0, 0, 0, 'A', 'A' }, &buffer);
}
