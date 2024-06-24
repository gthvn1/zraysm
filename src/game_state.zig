const r = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

pub const SpaceShip = struct {
    pos: r.Vector2,
    dots: []const r.Vector2, // dots

    pub fn init(position: r.Vector2) SpaceShip {
        return SpaceShip{
            .pos = position,
            .dots = &[_]r.Vector2{
                r.Vector2{ .x = -10, .y = 10 },
                r.Vector2{ .x = 0, .y = -10 },
                r.Vector2{ .x = 10, .y = 10 },
            },
        };
    }

    pub fn updatePos(self: *SpaceShip, v: r.Vector2) void {
        r.Vector2Add(self.pos, v);
    }

    pub fn draw(self: *SpaceShip) void {
        for (0..self.dots.len) |idx| {
            r.DrawLineV(
                r.Vector2Add(self.pos, self.dots[idx]),
                r.Vector2Add(self.pos, self.dots[(idx + 1) % self.dots.len]),
                r.BLACK,
            );
        }
    }
};
