const std = @import("std");
const commom = @import("../../src/utils/common.zig");
const size_t = u32;

test "memcpy for integers" {
    var dst = [6]u8{ 0, 0, 0, 0, 0, 0 };
    const src = &[6]u8{ 5, 5, 5, 5, 5, 5 };
    _ = commom.memcpy(&dst, src, 6);

    try std.testing.expectEqual(dst[0], src[0]);
    try std.testing.expectEqual(dst[5], src[5]);

    try std.testing.expect(std.mem.eql(u8, &dst, src));
}

test "memcpy for string" {
    var dst: [6]u8 = undefined;
    const src = "Hello!";
    _ = commom.memcpy(&dst, src, 6);

    try std.testing.expectEqualStrings(&dst, src);
}
