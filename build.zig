const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "zcb",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
    });

    exe.addIncludePath(b.path("c-src"));
    exe.addCSourceFiles(.{
        .root = b.path("c-src"),
        .files = &[_][]const u8{"foo.c"},
        .flags = &[_][]const u8{},
    });
    exe.linkLibC();

    b.installArtifact(exe);
}
