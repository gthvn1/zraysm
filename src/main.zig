const std = @import("std");

const r = @cImport({
    @cInclude("raylib.h");
});

const f = @cImport({
    @cInclude("foo.h");
});

pub fn main() void {
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
