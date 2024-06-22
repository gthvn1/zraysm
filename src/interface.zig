const Interface = struct {
    description: []const u8,
    inputs: []const type,
    output: type,
};

const gcd_params = [_]type{ i32, i32 };
pub const gcd = Interface{
    .description = "Compute the GCD of two numbers",
    .inputs = gcd_params[0..],
    .output = i32,
};

const positive_params = [_]type{i32};
pub const positive = Interface{
    .description = "return true if a number is greater or equal to 0, false otherwise",
    .inputs = positive_params[0..],
    .output = bool,
};
