#!/bin/bash
set -xue

QEMU=qemu-system-riscv32

zig build-exe kernel.zig \
  -target riscv32-freestanding-none \
  -T kernel.ld \
  --name kernel.elf \
  -O ReleaseSafe \

$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
  -kernel kernel.elf
