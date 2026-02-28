const size_t = u32;

extern var __bss: [0]u8;
extern var __bss_end: [0]u8;
extern var __stack_top: [0]u8;

const Sbiret = struct {
    error_code: isize, // long do c
    value: isize,
};

fn sbi_call(arg0: i32, arg1: i32, arg2: i32, arg3: i32, arg4: i32, arg5: i32, fid: i32, eid: i32) Sbiret {
    var err: isize = undefined;
    var val: isize = undefined;

    asm volatile ("ecall"
        : [err] "={a0}" (err),
          [val] "={a1}" (val),
        : [arg0] "={a0}" (arg0),
          [arg1] "={a1}" (arg1),
          [arg2] "={a2}" (arg2),
          [arg3] "={a3}" (arg3),
          [arg4] "={a4}" (arg4),
          [arg5] "={a5}" (arg5),
          [fid] "={a6}" (fid),
          [eid] "={a7}" (eid),
        : .{ .memory = true });

    return Sbiret{ .error_code = err, .value = val };
}

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
        \\la sp, __stack_top
        \\j kernel_main
    );
}
