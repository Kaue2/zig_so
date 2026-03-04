const std = @import("std");
const common = @import("common");
const size_t = u32;

extern var __bss: [0]u8;
extern var __bss_end: [0]u8;
extern var __stack_top: [0]u8;

fn panic(comptime src: std.builtin.SourceLocation, comptime fmt: [*]const u8, args: anytype) noreturn {
    common.printf("PANIC: %s:%d:%d: ", .{ src.file, src.line, src.column });

    common.printf(fmt, args);
    common.printf("\n", .{});

    while (true) {
        asm volatile ("wfi");
    }
}

export fn kernel_main() void {
    _ = common.memset(&__bss, 0, @intFromPtr(&__bss_end) - @intFromPtr(&__bss));

    const src = @src();
    panic(src, "booted!", .{});
    common.printf("unreachable\n");

    // while (true) {
    //     asm volatile ("wfi");
    // }
}

export fn boot() linksection(".text.boot") callconv(.naked) void {
    asm volatile (
        \\la sp, __stack_top
        \\j kernel_main
    );
}
