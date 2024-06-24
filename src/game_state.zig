const r = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

pub const SpaceShip = struct {
    pos: r.Vector2,
    angle: f32,
    velocity: f32,
    dots: []const r.Vector2, // dots

    pub fn init(position: r.Vector2) SpaceShip {
        return SpaceShip{
            .pos = position,
            .angle = 0.0,
            .velocity = 0.0,
            .dots = &[_]r.Vector2{
                r.Vector2{ .x = 0, .y = 0 }, // Remember that origin is at the upper left corner
                r.Vector2{ .x = -10, .y = 10 },
                r.Vector2{ .x = 0, .y = -20 },
                r.Vector2{ .x = 10, .y = 10 },
            },
        };
    }

    pub fn updatePos(self: *SpaceShip) void {
        const v = r.Vector2Scale(r.Vector2{
            .x = r.sinf(self.angle),
            .y = -r.cosf(self.angle),
        }, self.velocity);
        self.pos = r.Vector2Add(self.pos, v);

        // Decrease the velocity until 0 reached
        if (self.velocity > 0.0) {
            self.velocity -= 0.01;
        } else {
            self.velocity = 0.0;
        }
    }

    pub fn setVelocity(self: *SpaceShip, speed: f32) void {
        self.velocity = speed;
    }

    pub fn setAngle(self: *SpaceShip, degree: f32) void {
        self.angle = r.DEG2RAD * degree;
    }

    pub fn draw(self: *SpaceShip) void {
        for (0..self.dots.len) |idx| {
            // We first need to rotate and then move the dot to its position.
            r.DrawLineEx(
                r.Vector2Add(r.Vector2Rotate(self.dots[idx], self.angle), self.pos),
                r.Vector2Add(r.Vector2Rotate(self.dots[(idx + 1) % self.dots.len], self.angle), self.pos),
                1.5,
                r.RED,
            );
        }
    }
};
