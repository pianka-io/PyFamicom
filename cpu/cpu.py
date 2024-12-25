from time import sleep

from common.addressing import argument_size, Addressing
from common.constants import RESET_VECTOR, CPU_STATUS
from common.utilities import signed_byte
from cpu.memory import Memory
from cpu.op import ops_by_code, Op
from cpu.registers import Registers
from cpu.stack import Stack
from ppu.registers import Registers as PpuRegisters


class CPU:
    def __init__(self, ppu_registers: PpuRegisters, prg_rom: bytes):
        self.running = False
        self.ppu_registers = ppu_registers

        self.registers = Registers()
        self.memory = Memory(ppu_registers, prg_rom)
        self.stack = Stack(self.registers, self.memory)

        self.entry = self.memory.read_word(RESET_VECTOR)

    def start(self):
        self.running = True
        self.registers.PC = self.entry
        while self.running:
            opcode = self.memory.read_byte(self.registers.PC)
            if opcode not in ops_by_code:
                print(f"unsupported opcode: ${opcode:x}")
                break
            op = ops_by_code[opcode]
            arg = self.read_arg(op)
            self.print_instruction(op, arg)
            self.registers.PC += op.size
            self.handle_instruction(op, arg)

    def stop(self):
        self.running = False

    def print_instruction(self, op: Op, arg: int):
        rom_address = self.memory.translate_cpu_address_to_rom(self.registers.PC)
        assembler = op.assembler(arg)
        print(f"[${self.registers.PC:x}:${rom_address:x}] {assembler}")

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
            case "bpl": self.bpr(op, arg)
            case "jsr": self.jsr(op, arg)
            case "bit": self.bit(op, arg)
            case "pha": self.pha(op, arg)
            case "jmp": self.jmp(op, arg)
            case "rts": self.rts(op, arg)
            case "sei": self.sei(op, arg)
            case "iny": self.iny(op, arg)
            case "dex": self.dex(op, arg)
            case "dey": self.dey(op, arg)
            case "txa": self.txa(op, arg)
            case "tya": self.txa(op, arg)
            case "sta": self.sta(op, arg)
            case "stx": self.stx(op, arg)
            case "ldx": self.ldx(op, arg)
            case "ldy": self.ldy(op, arg)
            case "lda": self.lda(op, arg)
            case "cmp": self.cmp(op, arg)
            case "bne": self.bne(op, arg)
            case "inc": self.inc(op, arg)
            case "dec": self.inc(op, arg)
            case "nop": self.nop(op, arg)
            case "beq": self.beq(op, arg)
            case _:
                raise ValueError(f"unsupported instruction: {op.mnemonic}")

    def resolve_arg(self, op: Op, arg: int) -> int:
        match op.addressing:
            case Addressing.ABSOLUTE:
                return self.memory.read_byte(arg)
            case Addressing.IMMEDIATE:
                return arg
            case Addressing.ZERO:
                return arg
            case Addressing.RELATIVE:
                return self.memory.read_byte(self.registers.PC + signed_byte(arg))
            case Addressing.INDIRECT_INDEXED:
                low = self.memory.read_byte(arg)
                high = self.registers.Y
                address = int.from_bytes([high, low], byteorder='little')
                return self.memory.read_byte(address)
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def bpr(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        if not self.registers.is_p(CPU_STATUS.NEGATIVE):
            self.registers.PC = value

    def jsr(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                value = self.registers.PC.to_bytes(length=2, byteorder="little")
                self.stack.push(value[0])
                self.stack.push(value[1])
                self.registers.PC = arg

    def bit(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)

        # M7 -> N, M6 -> V
        nv = value & 0b11000000
        self.registers.clear_p(CPU_STATUS.NEGATIVE)
        self.registers.clear_p(CPU_STATUS.OVERFLOW)
        p = self.registers.P | nv
        self.registers.P = p

        # A AND M -> Z
        result = self.registers.A & value
        if result == 0:
            self.registers.set_p(CPU_STATUS.ZERO)
        else:
            self.registers.clear_p(CPU_STATUS.ZERO)

    def pha(self, op: Op, arg: int):
        self.stack.push(self.registers.A)

    def jmp(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.registers.PC = arg
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def rts(self, op: Op, arg: int):
        low = self.stack.pull()
        high = self.stack.pull()
        self.registers.PC = int.from_bytes([high, low], byteorder='little')

    def sei(self, op: Op, arg: int):
        self.registers.set_p(CPU_STATUS.INTERRUPT)

    def iny(self, op: Op, arg: int):
        self.registers.Y += 1

    def dex(self, op: Op, arg: int):
        self.registers.X -= 1

    def dey(self, op: Op, arg: int):
        self.registers.Y -= 1

    def txa(self, op: Op, arg: int):
        self.registers.A = self.registers.X

    def tya(self, op: Op, arg: int):
        self.registers.Y = self.registers.X

    def sta(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.memory.write_byte(arg, self.registers.A)
            case Addressing.ZERO:
                self.memory.write_byte(arg, self.registers.A)
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def stx(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.memory.write_byte(arg, self.registers.X)
            case Addressing.ZERO:
                self.memory.write_byte(arg, self.registers.X)
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def ldx(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.X = value

    def ldy(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.Y = value

    def lda(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.A = value

    def cmp(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        result = self.registers.A - value
        result = signed_byte(result)

        # N
        if result < 0:
            self.registers.set_p(CPU_STATUS.NEGATIVE)
        else:
            self.registers.clear_p(CPU_STATUS.NEGATIVE)

        # Z
        if result == 0:
            self.registers.set_p(CPU_STATUS.ZERO)
        else:
            self.registers.clear_p(CPU_STATUS.ZERO)

        # C
        if result < -128 or result > 127:
            self.registers.set_p(CPU_STATUS.CARRY)
        else:
            self.registers.clear_p(CPU_STATUS.CARRY)

    def bne(self, op: Op, arg: int):
        if not self.registers.is_p(CPU_STATUS.ZERO):
            value = self.registers.PC + signed_byte(arg)
            self.registers.PC = value

    def inc(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg) + 1
        self.memory.write_byte(arg, value)

    def dec(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg) - 1
        self.memory.write_byte(arg, value)

    def nop(self, op: Op, arg: int):
        ...

    def beq(self, op: Op, arg: int):
        if self.registers.is_p(CPU_STATUS.ZERO):
            value = self.resolve_arg(op, arg)
            self.registers.PC = value
