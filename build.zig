const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add the STB submodule include path
    const stb_include_path = b.path("lib/stb");

    // Static library
    const lib = b.addStaticLibrary(.{
        .name = "chromasampler",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // Executable
    const exe = b.addExecutable(.{
        .name = "chromasampler",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add the args dependency
    exe.root_module.addImport("args", b.dependency("args", .{ .target = target, .optimize = optimize }).module("args"));

    // Link libc and math library
    exe.linkLibC();
    exe.linkSystemLibrary("m");

    // Add STB include path to the executable
    exe.addIncludePath(stb_include_path);

    // Define STB_IMAGE_IMPLEMENTATION in Zig
    exe.root_module.addCMacro("STB_IMAGE_IMPLEMENTATION", "1");

    // Install the executable
    b.installArtifact(exe);

    // Run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Unit tests for the library
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Unit tests for the executable
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
