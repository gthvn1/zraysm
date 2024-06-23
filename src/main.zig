const std = @import("std");
const wat = @import("wat.zig");

const r = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

const f = @cImport({
    @cInclude("foo.h");
});

pub fn connectDots(position: r.Vector2, dots: []r.Vector2) void {
    for (0..dots.len) |idx| {
        r.DrawLineV(
            r.Vector2Add(position, dots[idx]),
            r.Vector2Add(position, dots[(idx + 1) % dots.len]),
            r.BLACK,
        );
    }
}

pub fn main() !void {
    // ----------------------- R A Y L I B ------------------------------------
    r.InitWindow(800, 600, "Raylib in Zig");
    while (!r.WindowShouldClose()) {
        // Start drawing
        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);

        var dots = [_]r.Vector2{
            r.Vector2{ .x = -10, .y = 10 },
            r.Vector2{ .x = 0, .y = -10 },
            r.Vector2{ .x = 10, .y = 10 },
        };

        connectDots(r.Vector2{ .x = 100, .y = 100 }, dots[0..]);
        connectDots(r.Vector2{ .x = 100, .y = 200 }, dots[0..]);

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
