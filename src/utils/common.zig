const sbi = @import("sbi");
const size_t = u32;

pub fn memcpy(dst: *anyopaque, src: *anyopaque, n: size_t) *anyopaque {
    var d: [*]u8 = @ptrCast(dst);
    const s: [*]u8 = @ptrCast(src);
    var i: usize = 0;

    while (i < n) : (i += 1) {
        d[i] = s[i];
    }

    return d;
}

pub fn memset(buf: *anyopaque, char: u8, n: size_t) *anyopaque {
    var b: [*]u8 = @ptrCast(buf);
    var i: size_t = 0;

    while (i < n) : (i += 1) {
        b[i] = char;
    }

    return buf;
}

pub fn strcpy(dst: [*]u8, src: [*]const u8) [*]u8 {
    var i: size_t = 0;

    while (src[i] != 0) : (i += 1) {
        dst[i] = src[i];
    }
    dst[i] = 0;
    return dst;
}

pub fn strcmp(str1: [*]const u8, str2: [*]const u8) i32 {
    var i: size_t = 0;

    while (str1[i] != 0 and str2[i] != 0) : (i += 1) {
        if (str1[i] != str2[i])
            break;
    }

    return str1[i] - str2[i];
}

pub fn printf(comptime string: [*]const u8, args: anytype) void {
    comptime var arg_idx = 0;

    comptime var i: usize = 0;
    inline while (string[i] != 0) : (i += 1) {
        if (string[i] == '%') {
            i += 1; // pulando %
            switch (string[i]) {
                0 => {
                    sbi.putchar('%');
                    return;
                },
                '%' => {
                    sbi.putchar('%');
                },
                's' => {
                    const s: [*]const u8 = args[arg_idx];
                    arg_idx += 1;
                    var aux: usize = 0;
                    while (s[aux] != 0) : (aux += 1) {
                        sbi.putchar(s[aux]);
                    }
                },
                'd' => {
                    const value: i32 = args[arg_idx];
                    arg_idx += 1;
                    var magnitude: u32 = @bitCast(value);

                    if (value < 0) {
                        sbi.putchar('-');
                        magnitude = @intCast(-value);
                    }

                    var divisor: u32 = 1;
                    while (divisor > 0) {
                        const character = '0' + magnitude / divisor;
                        sbi.putchar(@intCast(character));
                        magnitude %= divisor;
                        divisor /= 10;
                    }
                },
                'x' => {
                    const value: i32 = args[arg_idx];
                    arg_idx += 1;
                    for (7..-1) |idx| {
                        const nibble: u32 = (value >> (idx * 4)) & 0xf;
                        const character = "0123456789abcdef"[nibble];
                        sbi.putchar(@intCast(character));
                    }
                },
                else => {
                    sbi.putchar(string[i]);
                },
            }
        } else {
            sbi.putchar(string[i]);
        }
    }
}
