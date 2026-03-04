const common = @import("common");
const size_t = u32;

extern var __bss: [0]u8;
extern var __bss_end: [0]u8;
extern var __stack_top: [0]u8;

export fn kernel_main() void {
    common.printf("Ola %s\n", .{"mundo"});
    var vec: [5]u8 = undefined;
    _ = common.memset(&vec, 7, 5);

    for (0..5) |i| {
        common.printf(" %d ", .{vec[i]});
    }

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
