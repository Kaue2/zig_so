#!/bin/bash
set -xue

QEMU=qemu-system-riscv32

zig build -Doptimize=ReleaseSafe

$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
  -kernel zig-out/bin/kernel.elf
