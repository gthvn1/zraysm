const std = @import("std");
const json = std.json;

const FuncSig = struct {
    inputs: [][]u8,
    output: []u8,
};

const Interface = struct {
    funcs: ?[]FuncSig,
    pub fn init(json_str: []const u8) Interface {
        _ = json_str;
        return Interface{
            .funcs = null,
        };
    }
};

test "empty_interface" {
    const json_str = "{}";
    const interface = Interface.init(json_str[0..]);
    var empty: bool = true;
    if (interface.funcs) |_| {
        empty = false;
    }
    try std.testing.expect(empty == true);
}

test "gcd_interface" {
    const json_str =
        \\ {
        \\  gcd: {
        \\      inputs: ["i32", "i32"],
        \\      output: "i32",
        \\  }
        \\ }
    ;
    _ = Interface.init(json_str[0..]);
}

test "gcd_abs_interface" {
    const json_str =
        \\ {
        \\  gcd: {
        \\      inputs: ["i32", "i32"],
        \\      output: "i32",
        \\  },
        \\  abs: {
        \\      inputs: ["i32"],
        \\      output: "i32",
        \\  }
        \\ }
    ;
    _ = Interface.init(json_str[0..]);
}
