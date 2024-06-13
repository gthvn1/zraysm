const std = @import("std");

const c = @cImport({
    @cInclude("foo.h");
});

pub fn main() void {
    const v = c.foo(30, 12);
    std.debug.print("The answer is {d}", .{v});
}
