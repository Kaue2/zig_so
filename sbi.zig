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
        : [arg0] "{a0}" (arg0),
          [arg1] "{a1}" (arg1),
          [arg2] "{a2}" (arg2),
          [arg3] "{a3}" (arg3),
          [arg4] "{a4}" (arg4),
          [arg5] "{a5}" (arg5),
          [fid] "{a6}" (fid),
          [eid] "{a7}" (eid),
        : .{ .memory = true });

    return Sbiret{ .error_code = err, .value = val };
}

pub fn putchar(ch: u8) void {
    _ = sbi_call(ch, 0, 0, 0, 0, 0, 0, 1);
}
