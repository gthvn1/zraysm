const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "zraysm",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
    });

    // Link with raylib/libraylib.a
    // We are expecting the header and the library into raylib/
    exe.linkLibC();
    exe.addObjectFile(b.path("raylib/libraylib.a"));
    exe.addIncludePath(b.path("raylib"));

    // Link with wasmer
    exe.addObjectFile(b.path("wasmer/lib/libwasmer.so"));
    exe.addIncludePath(b.path("wasmer/include"));

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
