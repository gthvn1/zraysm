const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "zaylib",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
    });

    // Link with raylib/libraylib.a
    // We are expecting the header and the library into raylib/
    exe.linkLibC();
    exe.addObjectFile(b.path("raylib/libraylib.a"));
    exe.addIncludePath(b.path("raylib"));

    // Link with wasmtime
    exe.addObjectFile(b.path("wasmtime-v21.0.1-x86_64-linux-c-api/lib/libwasmtime.so"));
    exe.addIncludePath(b.path("wasmtime-v21.0.1-x86_64-linux-c-api/include"));

    exe.addIncludePath(b.path("raylib"));

    // Also build and link with our own library
    exe.addIncludePath(b.path("c-src"));
    exe.addCSourceFiles(.{
        .root = b.path("c-src"),
        .files = &[_][]const u8{"foo.c"},
        .flags = &[_][]const u8{},
    });

    // Now build
    b.installArtifact(exe);

    // TODO: add run step, test step, ...
}
