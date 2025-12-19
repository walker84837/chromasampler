const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    main_module.addImport("args", b.dependency("args", .{ .target = target, .optimize = optimize }).module("args"));
    const zstbi = b.dependency("zstbi", .{});
    main_module.addImport("zstbi", zstbi.module("root"));

    const exe = b.addExecutable(.{
        .name = "chromasampler",
        .root_module = main_module,
    });

    exe.linkLibC();
    exe.linkSystemLibrary("m");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_test_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_test_module.addImport("args", b.dependency("args", .{ .target = target, .optimize = optimize }).module("args"));
    exe_test_module.addImport("zstbi", zstbi.module("root"));

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_test_module,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
