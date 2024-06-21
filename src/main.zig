const std = @import("std");
const wat = @import("wat.zig");

const r = @cImport({
    @cInclude("raylib.h");
});

const f = @cImport({
    @cInclude("foo.h");
});

pub fn main() !void {
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

    // ----------------------- R A Y L I B ------------------------------------
    r.InitWindow(800, 600, "Raylib in Zig");
    while (!r.WindowShouldClose()) {
        // Start drawing
        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        r.DrawText(
            "All your codebase are belong to us.",
            190,
            200,
            20,
            r.LIGHTGRAY,
        );
        r.EndDrawing();
    }

    r.CloseWindow();

    const answer = f.foo(30, 12);
    std.debug.print("{d} is the answer to the Ultimate Question of Life, the Universe, and Everything", .{answer});
}
