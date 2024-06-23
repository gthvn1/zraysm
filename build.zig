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
    exe.addIncludePath(b.path("src/c"));
    exe.addCSourceFiles(.{
        .root = b.path("src/c"),
        .files = &[_][]const u8{"foo.c"},
        .flags = &[_][]const u8{},
    });

    // Now build
    b.installArtifact(exe);

    // Create the run step
    const run_cmd = b.addRunArtifact(exe);
    // Run depends of the install step
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.setEnvironmentVariable("LD_LIBRARY_PATH", "./wasmer/lib/");
    run_cmd.addArg("./src/wat/gcd.wat");

    const run_step = b.step("run", "Run zayasm using ./src/wat/gdc.wat");
    run_step.dependOn(&run_cmd.step);

    // Create a test for testing interface
    const interface_test = b.addTest(.{
        .root_source_file = b.path("src/interface.zig"),
        .target = target,
    });
    const run_interface_test = b.addRunArtifact(interface_test);

    // Add the step test and add the test of interface
    const test_step = b.step("test", "Run unit test");
    test_step.dependOn(&run_interface_test.step);
}
