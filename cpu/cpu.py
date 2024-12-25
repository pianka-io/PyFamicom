from time import sleep

from common.addressing import argument_size, Addressing
from common.constants import RESET_VECTOR, CPU_STATUS_INTERRUPT, CPU_STATUS_OVERFLOW, CPU_STATUS_NEGATIVE, \
    CPU_STATUS_ZERO
from common.utilities import signed_byte
from cpu.memory import Memory
from cpu.op import ops_by_code, Op
from cpu.registers import Registers
from ppu.registers import Registers as PpuRegisters


class CPU:
    def __init__(self, ppu_registers: PpuRegisters, prg_rom: bytes):
        self.running = False
        self.ppu_registers = ppu_registers
        self.registers = Registers()
        self.memory = Memory(ppu_registers, prg_rom)
        self.entry = self.memory.read_word(RESET_VECTOR)

    def start(self):
        self.running = True
        self.registers.PC = self.entry
        while self.running:
            sleep(0.1)
            opcode = self.memory.read_byte(self.registers.PC)
            if opcode not in ops_by_code:
                print(f"unsupported opcode: ${opcode:x}")
                break
            op = ops_by_code[opcode]
            arg = self.read_arg(op)
            self.registers.PC += op.size
            self.print_instruction(op, arg)
            self.handle_instruction(op, arg)

    def stop(self):
        self.running = False

    def print_instruction(self, op: Op, arg: int):
        rom_address = self.memory.translate_cpu_address_to_rom(self.registers.PC)
        print(f"[${self.registers.PC:x}:${rom_address:x}] {op.mnemonic} ${arg:x}")

    def read_arg(self, op: Op) -> int:
        begin = self.registers.PC + 1
        size = argument_size(op.addressing)
        if size == 0:
            return 0
        if size == 1:
            return self.memory.read_byte(begin)
        if size == 2:
            return self.memory.read_word(begin)
        raise ValueError(f"unsupported argument size: {size}")

    def handle_instruction(self, op: Op, arg: int):
        match op.mnemonic:
            case "bpl":
                self.bpr(op, arg)
            case "jsr":
                self.jsr(op, arg)
            case "bit":
                self.bit(op, arg)
            case "sei":
                self.sei()
            case "sta":
                self.sta(op, arg)
            case "lda":
                self.lda(op, arg)
            case _:
                raise ValueError(f"unsupported instruction: {op.mnemonic}")

    def resolve_arg(self, op: Op, arg: int) -> int:
        match op.addressing:
            case Addressing.ABSOLUTE:
                return self.memory.read_byte(arg)
            case Addressing.IMMEDIATE:
                return arg
            case Addressing.RELATIVE:
                return self.registers.PC + signed_byte(arg)
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def bpr(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        if not self.registers.is_p(CPU_STATUS_NEGATIVE):
            self.registers.PC = value

    def jsr(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.registers.PC = arg

    def bit(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)

        # M7 -> N, M6 -> V
        nv = value & 0b11000000
        self.registers.unset_p(CPU_STATUS_NEGATIVE)
        self.registers.unset_p(CPU_STATUS_OVERFLOW)
        p = self.registers.P | nv
        self.registers.P = p

        # A AND M -> Z
        result = self.registers.A & value
        if result == 0:
            self.registers.set_p(CPU_STATUS_ZERO)
        else:
            self.registers.unset_p(CPU_STATUS_ZERO)

    def sei(self):
        self.registers.set_p(CPU_STATUS_INTERRUPT)

    def sta(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.memory.write_byte(arg, self.registers.A)
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def lda(self, op: Op, arg: int) -> bool:
        value = self.resolve_arg(op, arg)
        self.registers.A = value
