const r = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

fn connectDots(position: r.Vector2, dots: []r.Vector2) void {
    for (0..dots.len) |idx| {
        r.DrawLineV(
            r.Vector2Add(position, dots[idx]),
            r.Vector2Add(position, dots[(idx + 1) % dots.len]),
            r.BLACK,
        );
    }
}

pub const GameState = struct {
    width: usize,
    height: usize,

    pub fn init(width: usize, height: usize) GameState {
        return GameState{
            .width = width,
            .height = height,
        };
    }

    pub fn update(self: *GameState) void {
        _ = self;

        // Start drawing
        r.BeginDrawing();
        defer r.EndDrawing();

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
    }
};
