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

    // Start with the ship in the middle of the window
    var ship = game_state.SpaceShip.init(r.Vector2{
        .x = @as(f32, @floatFromInt(win_width / 2)),
        .y = @as(f32, @floatFromInt(win_height / 2)),
    });

    // Start with a speed of 2.0
    ship.setVelocity(2.0);
    // Start by going down
    ship.setAngle(180.0);

    r.InitWindow(win_width, win_height, "Zraysm");
    r.SetTargetFPS(60);

    while (!r.WindowShouldClose()) {
        // Start drawing
        r.BeginDrawing();
        defer r.EndDrawing();

        r.ClearBackground(r.RAYWHITE);

        ship.updatePos();
        //ship.updateAngle(0.01);
        ship.draw();

        r.DrawText(
            "All your codebase are belong to us.",
            190,
            200,
            20,
            r.LIGHTGRAY,
        );
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
