const commom = @import("common.zig");
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
    commom.printf("\n\n Hello %s\n", .{"World"});
    commom.printf("\n\n 1 + 2 = %d \n\n", .{1 + 2});

    while (true) {
        asm volatile ("wfi");
    }
}

export fn boot() linksection(".text.boot") callconv(.naked) void {
    asm volatile (
        \\la sp, __stack_top
        \\j kernel_main
    );
}
