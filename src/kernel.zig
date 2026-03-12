const std = @import("std");
const common = @import("common");

extern var __bss: u8;
extern var __bss_end: u8;
extern var __stack_top: u8;
extern var __free_ram: u8;
extern var __free_ram_end: u8;

const PAGE_SIZE: usize = 4096;

const TrapFrame = packed struct {
    ra: u32,
    gp: u32,
    tp: u32,
    t0: u32,
    t1: u32,
    t2: u32,
    t3: u32,
    t4: u32,
    t5: u32,
    t6: u32,
    a0: u32,
    a1: u32,
    a2: u32,
    a3: u32,
    a4: u32,
    a5: u32,
    a6: u32,
    a7: u32,
    s0: u32,
    s1: u32,
    s2: u32,
    s3: u32,
    s4: u32,
    s5: u32,
    s6: u32,
    s7: u32,
    s8: u32,
    s9: u32,
    s10: u32,
    s11: u32,
    sp: u32,
};

fn kernel_entry() align(4) callconv(.naked) void {
    asm volatile (
        \\csrw sscratch, sp
        \\addi sp, sp, -4 * 31
        \\sw ra, 4 * 0(sp)
        \\sw gp, 4 * 1(sp)
        \\sw tp, 4 * 2(sp)
        \\sw t0, 4 * 3(sp)
        \\sw t1, 4 * 4(sp)
        \\sw t2, 4 * 5(sp)
        \\sw t3, 4 * 6(sp)
        \\sw t4, 4 * 7(sp)
        \\sw t5, 4 * 8(sp)
        \\sw t6, 4 * 9(sp)
        \\sw a0, 4 * 10(sp)
        \\sw a1, 4 * 11(sp)
        \\sw a2, 4 * 12(sp)
        \\sw a3, 4 * 13(sp)
        \\sw a4, 4 * 14(sp)
        \\sw a5, 4 * 15(sp)
        \\sw a6, 4 * 16(sp)
        \\sw a7, 4 * 17(sp)
        \\sw s0, 4 * 18(sp)
        \\sw s1, 4 * 19(sp)
        \\sw s2, 4 * 20(sp)
        \\sw s3, 4 * 21(sp)
        \\sw s4, 4 * 22(sp)
        \\sw s5, 4 * 23(sp)
        \\sw s6, 4 * 24(sp)
        \\sw s7, 4 * 25(sp)
        \\sw s8, 4 * 26(sp)
        \\sw s9, 4 * 27(sp)
        \\sw s10, 4 * 28(sp)
        \\sw s11, 4 * 29(sp)
        \\csrr a0, sscratch
        \\sw a0, 4 * 30(sp)
        \\mv a0, sp
        \\call handle_trap
        \\lw ra, 4 * 0(sp)
        \\lw gp, 4 * 1(sp)
        \\lw tp, 4 * 2(sp)
        \\lw t0, 4 * 3(sp)
        \\lw t1, 4 * 4(sp)
        \\lw t2, 4 * 5(sp)
        \\lw t3, 4 * 6(sp)
        \\lw t4, 4 * 7(sp)
        \\lw t5, 4 * 8(sp)
        \\lw t6, 4 * 9(sp)
        \\lw a0, 4 * 10(sp)
        \\lw a1, 4 * 11(sp)
        \\lw a2, 4 * 12(sp)
        \\lw a3, 4 * 13(sp)
        \\lw a4, 4 * 14(sp)
        \\lw a5, 4 * 15(sp)
        \\lw a6, 4 * 16(sp)
        \\lw a7, 4 * 17(sp)
        \\lw s0, 4 * 18(sp)
        \\lw s1, 4 * 19(sp)
        \\lw s2, 4 * 20(sp)
        \\lw s3, 4 * 21(sp)
        \\lw s4, 4 * 22(sp)
        \\lw s5, 4 * 23(sp)
        \\lw s6, 4 * 24(sp)
        \\lw s7, 4 * 25(sp)
        \\lw s8, 4 * 26(sp)
        \\lw s9, 4 * 27(sp)
        \\lw s10, 4 * 28(sp)
        \\lw s11, 4 * 29(sp)
        \\lw sp, 4 * 30(sp)
        \\sret
    );
}

fn panic(comptime src: std.builtin.SourceLocation, comptime fmt: [*]const u8, args: anytype) noreturn {
    common.printf("PANIC: %s:%d:%d: ", .{ src.file, src.line, src.column });

    common.printf(fmt, args);
    common.printf("\n", .{});

    while (true) {
        asm volatile ("wfi");
    }
}

export fn handle_trap(f: *TrapFrame) void {
    const scause = asm volatile ("csrr %[ret], scause"
        : [ret] "=r" (-> u32),
    );
    const stval = asm volatile ("csrr %[ret], stval"
        : [ret] "=r" (-> u32),
    );
    const user_pc = asm volatile ("csrr %[ret], sepc"
        : [ret] "=r" (-> u32),
    );

    const src = @src();
    panic(src, "unexpected trap scause=%x stval=%x sepc=%x ra=%x", .{ scause, stval, user_pc, f.ra });
}

fn alloc_pages(n: u32) usize {
    common.printf("Free ram: %x\n", .{@intFromPtr(&__free_ram)});
    common.printf("Free ram end: %x\n", .{@intFromPtr(&__free_ram_end)});
    var next_paddr: usize = @intFromPtr(&__free_ram);
    var paddr: usize = next_paddr;
    next_paddr += n * PAGE_SIZE;

    if (next_paddr > @intFromPtr(&__free_ram_end)) {
        const src = @src();
        panic(src, "out of memory", .{});
    }

    _ = common.memset(&paddr, 0, n * PAGE_SIZE);

    return paddr;
}

export fn kernel_main() void {
    _ = common.memset(&__bss, 0, @intFromPtr(&__bss_end) - @intFromPtr(&__bss));
    asm volatile ("csrw stvec, %[addr]"
        :
        : [addr] "r" (&kernel_entry),
    );

    const paddr0: usize = alloc_pages(2);
    const paddr1: usize = alloc_pages(1);
    common.printf("alloc_pages test: paddr0=%x\n", .{paddr0});
    common.printf("alloc_pages test: paddr1=%x", .{paddr1});

    asm volatile ("unimp");

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
