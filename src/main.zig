const std = @import("std");
const wat = @import("wat.zig");
const game_state = @import("game_state.zig");

const r = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

const f = @cImport({
    @cInclude("foo.h");
});

pub fn main() !void {
    // ----------------------- R A Y L I B ------------------------------------
    const win_width = 800;
    const win_height = 600;
    var state = game_state.GameState.init(win_width, win_height);

    r.InitWindow(win_width, win_height, "Raylib in Zig");

    while (!r.WindowShouldClose()) {
        state.update();
    }

    r.CloseWindow();

    // ----------------------- W A S M E R ------------------------------------
    var func_args = std.process.args();
    // We expect the WAT file name as the first parameter
    // Skip the first args that is the name of the program
    _ = func_args.skip();
    const watf_opt = func_args.next();

    if (watf_opt) |wat_filename| {
        try wat.build_and_run_wat(wat_filename);
    } else {
        std.debug.print("WASM part skipped because no WAT filename provided\n", .{});
    }

    // ------------------ R U N  O U R  "C"  C O D E --------------------------
    const answer = f.foo(30, 12);
    std.debug.print("{d} is the answer to the Ultimate Question of Life, the Universe, and Everything", .{answer});
}
