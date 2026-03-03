const std = @import("std");

pub fn build(b: *std.Build) void {
    const kernel_target_query = std.Target.Query{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .none,
    };
    const target = b.resolveTargetQuery(kernel_target_query);
    const optimize = b.standardOptimizeOption(.{});

    const common_module = b.addModule("common", .{
        .root_source_file = b.path("src/utils/common.zig"),
    });

    const sbi_module = b.addModule("sbi", .{
        .root_source_file = b.path("src/console/sbi.zig"),
    });

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/kernel.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    kernel.root_module.addImport("common", common_module);
    kernel.root_module.addImport("sbi", sbi_module);
    kernel.setLinkerScript(b.path("src/linker/kernel.ld"));

    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/test/test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    unit_tests.root_module.addImport("common", common_module);
    unit_tests.root_module.addImport("sbi", sbi_module);

    b.installArtifact(kernel);

    const run_init_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Roda os testes unitários do sistema");
    test_step.dependOn(&run_init_tests.step);
}
