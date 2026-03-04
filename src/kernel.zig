const common = @import("common");
const size_t = u32;

extern var __bss: [0]u8;
extern var __bss_end: [0]u8;
extern var __stack_top: [0]u8;

export fn kernel_main() void {
    const str1 = "string";
    const str2 = "string";
    const ret: i32 = common.strcmp(str1, str2);

    if (ret == 0) {
        common.printf("As strings eram iguais\n", .{});
    } else {
        common.printf("As strings eram diferentes\n", .{});
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
