from time import sleep

from common.addressing import argument_size, Addressing
from common.constants import RESET_VECTOR, CPU_STATUS, NMI_VECTOR
from common.interrupt import Interrupt
from common.utilities import signed_byte
from cpu.memory import Memory
from cpu.opcodes import ops_by_code, Op
from cpu.registers import Registers
from cpu.stack import Stack
from ppu.ppu import PPU


class CPU:
    def __init__(self, ppu: PPU, nmi: Interrupt, prg_rom: bytes):
        self.running = False
        self.cycles = 0
        self.ppu = ppu
        self.nmi = nmi

        self.registers = Registers()
        self.memory = Memory(self.ppu, prg_rom)
        self.stack = Stack(self.registers, self.memory)

        self.entry = self.memory.read_word(RESET_VECTOR)

    def start(self):
        self.running = True
        self.registers.PC = self.entry
        while self.running:
            # ppu nmi interrupt
            if self.nmi.active():
                self.nmi.clear()
                self.stack.push(self.registers.PC >> 8)
                self.stack.push(self.registers.PC)
                self.stack.push(self.registers.P)
                self.registers.PC = self.memory.read_byte(NMI_VECTOR) | (self.memory.read_byte(NMI_VECTOR + 1) << 8)
                continue

            # regular operation
            opcode = self.memory.read_byte(self.registers.PC)
            if opcode not in ops_by_code:
                print(f"unsupported opcode: ${opcode:x}")
                break
            op = ops_by_code[opcode]
            arg = self.read_arg(op)

            self.print_instruction(op, arg)
            self.registers.PC += op.size
            self.handle_instruction(op, arg)
            self.cycles += op.cycles

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
            case "bpl":
                self.bpl(op, arg)
            case "clc":
                self.clc(op, arg)
            case "jsr":
                self.jsr(op, arg)
            case "and":
                self.and_(op, arg)
            case "bit":
                self.bit(op, arg)
            case "pha":
                self.pha(op, arg)
            case "rti":
                self.rti(op, arg)
            case "jmp":
                self.jmp(op, arg)
            case "rts":
                self.rts(op, arg)
            case "pla":
                self.pla(op, arg)
            case "adc":
                self.adc(op, arg)
            case "sei":
                self.sei(op, arg)
            case "iny":
                self.iny(op, arg)
            case "dex":
                self.dex(op, arg)
            case "dey":
                self.dey(op, arg)
            case "txa":
                self.txa(op, arg)
            case "tya":
                self.txa(op, arg)
            case "tax":
                self.tax(op, arg)
            case "tay":
                self.tay(op, arg)
            case "sta":
                self.sta(op, arg)
            case "stx":
                self.stx(op, arg)
            case "sty":
                self.sty(op, arg)
            case "ldx":
                self.ldx(op, arg)
            case "ldy":
                self.ldy(op, arg)
            case "lda":
                self.lda(op, arg)
            case "cmp":
                self.cmp(op, arg)
            case "bne":
                self.bne(op, arg)
            case "inc":
                self.inc(op, arg)
            case "inx":
                self.inx(op, arg)
            case "dec":
                self.dec(op, arg)
            case "nop":
                self.nop(op, arg)
            case "beq":
                self.beq(op, arg)
            case _:
                raise ValueError(f"unsupported instruction: {op.mnemonic}")

    def resolve_arg(self, op: Op, arg: int) -> int:
        match op.addressing:
            case Addressing.ABSOLUTE:
                return self.memory.read_byte(arg)
            case Addressing.ABSOLUTE_X:
                address = self.registers.X + arg
                return self.memory.read_byte(address)
            case Addressing.IMMEDIATE:
                return arg
            case Addressing.ZERO:
                return self.memory.read_byte(arg)
            case Addressing.RELATIVE:
                return self.memory.read_byte(self.registers.PC + signed_byte(arg))
            case Addressing.INDIRECT_INDEXED:
                low = self.memory.read_byte(arg)
                high = self.registers.Y & 0xFF
                address = int.from_bytes([high, low], byteorder='little')
                return self.memory.read_byte(address)
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def set_n_by(self, value: int):
        if value < 0:
            self.registers.set_p(CPU_STATUS.NEGATIVE)
        else:
            self.registers.clear_p(CPU_STATUS.NEGATIVE)

    def set_z_by(self, value: int):
        if value == 0:
            self.registers.set_p(CPU_STATUS.ZERO)
        else:
            self.registers.clear_p(CPU_STATUS.ZERO)

    def set_c_by(self, value: int):
        if value < -128 or value > 127:
            self.registers.set_p(CPU_STATUS.CARRY)
        else:
            self.registers.clear_p(CPU_STATUS.CARRY)

    def set_v_by(self, value: int):
        if not (value >> 8) == 0:
            self.registers.set_p(CPU_STATUS.CARRY)
        else:
            self.registers.clear_p(CPU_STATUS.CARRY)

    def bpl(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        if not self.registers.is_p(CPU_STATUS.NEGATIVE):
            self.registers.PC = value

    def clc(self, op: Op, arg: int):
        self.registers.clear_p(CPU_STATUS.CARRY)

    def jsr(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                value = self.registers.PC.to_bytes(length=2, byteorder="little")
                self.stack.push(value[0])
                self.stack.push(value[1])
                self.registers.PC = arg

    def and_(self, op: Op, arg: int):
        a = self.registers.A
        value = a & arg
        self.registers.A = value

        self.set_n_by(value)
        self.set_z_by(value)

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

    def rti(self, op: Op, arg: int):
        self.registers.P = self.stack.pull()
        low = self.stack.pull()
        high = self.stack.pull()
        self.registers.PC = (high << 8) | low

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

    def pla(self, op: Op, arg: int):
        value = self.stack.pull()
        self.registers.A = value
        self.set_n_by(value)
        self.set_z_by(value)

    def adc(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        total = self.registers.A + value
        self.registers.A = total & 0xFF

        self.set_n_by(value)
        self.set_z_by(value)
        self.set_c_by(value)
        self.set_v_by(value)

    def sei(self, op: Op, arg: int):
        self.registers.set_p(CPU_STATUS.INTERRUPT)

    def iny(self, op: Op, arg: int):
        self.registers.Y += 1
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    def dex(self, op: Op, arg: int):
        self.registers.X -= 1
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def dey(self, op: Op, arg: int):
        self.registers.Y -= 1
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    def txa(self, op: Op, arg: int):
        self.registers.A = self.registers.X
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    def tya(self, op: Op, arg: int):
        self.registers.A = self.registers.Y
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    def tax(self, op: Op, arg: int):
        self.registers.X = self.registers.A
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def tay(self, op: Op, arg: int):
        self.registers.Y = self.registers.A
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

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

    def sty(self, op: Op, arg: int):
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.memory.write_byte(arg, self.registers.Y)
            case Addressing.ZERO:
                self.memory.write_byte(arg, self.registers.Y)
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def ldx(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.X = value
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def ldy(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.Y = value
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    def lda(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.A = value
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    def cmp(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        result = self.registers.A - value
        result = signed_byte(result)

        self.set_n_by(result)
        self.set_z_by(result)
        self.set_c_by(result)

    def bne(self, op: Op, arg: int):
        if not self.registers.is_p(CPU_STATUS.ZERO):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    def inc(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg) + 1
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    def inx(self, op: Op, arg: int):
        self.registers.X += 1
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def dec(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg) - 1
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    def nop(self, op: Op, arg: int):
        ...

    def beq(self, op: Op, arg: int):
        if self.registers.is_p(CPU_STATUS.ZERO):
            self.registers.PC = self.registers.PC + signed_byte(arg)
