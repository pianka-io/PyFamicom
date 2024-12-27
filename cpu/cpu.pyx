from time import sleep

from com.addressing import argument_size, Addressing
from com.clock import Clock
from com.constants import RESET_VECTOR, CPU_STATUS, NMI_VECTOR
from com.interrupt import Interrupt
from com.utilities import signed_byte
from cpu.memory import Memory
from cpu.opcodes import ops_by_code, Op
from cpu.registers import Registers
from cpu.stack import Stack
from ppu.ppu import PPU


class CPU:
    def __init__(self, clock: Clock, ppu: PPU, nmi: Interrupt, prg_rom: bytes):
        self.running = False
        self.clock = clock
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
            sleep(0)
            # clock synchronization
            if not self.clock.cpu_ready():
                # sleep(0.000001)  # 1 microsecond
                sleep(0)

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

            # self.print_instruction(op, arg)
            self.registers.PC += op.size
            self.handle_instruction(op, arg)
            self.clock.cpu_cycles += op.cycles
            # self.print_registers()

    def stop(self):
        self.running = False

    def print_instruction(self, op: Op, arg: int):
        rom_address = self.memory.translate_cpu_address_to_rom(self.registers.PC)
        assembler = op.assembler(arg)
        print(f"[${self.registers.PC:x}:${rom_address:x}] {assembler}")

    def print_registers(self):
        print(f"P b{self.registers.P:08b} SP ${self.registers.SP:x} A ${self.registers.A:x} X ${self.registers.X:x} Y ${self.registers.Y:x}")

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
        if op.mnemonic == "bpl":
            self.bpl(op, arg)
        elif op.mnemonic == "clc":
            self.clc(op, arg)
        elif op.mnemonic == "jsr":
            self.jsr(op, arg)
        elif op.mnemonic == "and":
            self.and_(op, arg)
        elif op.mnemonic == "bit":
            self.bit(op, arg)
        elif op.mnemonic == "pha":
            self.pha(op, arg)
        elif op.mnemonic == "rti":
            self.rti(op, arg)
        elif op.mnemonic == "jmp":
            self.jmp(op, arg)
        elif op.mnemonic == "rts":
            self.rts(op, arg)
        elif op.mnemonic == "pla":
            self.pla(op, arg)
        elif op.mnemonic == "adc":
            self.adc(op, arg)
        elif op.mnemonic == "sei":
            self.sei(op, arg)
        elif op.mnemonic == "iny":
            self.iny(op, arg)
        elif op.mnemonic == "dex":
            self.dex(op, arg)
        elif op.mnemonic == "dey":
            self.dey(op, arg)
        elif op.mnemonic == "txa":
            self.txa(op, arg)
        elif op.mnemonic == "tya":
            self.tya(op, arg)
        elif op.mnemonic == "tax":
            self.tax(op, arg)
        elif op.mnemonic == "tay":
            self.tay(op, arg)
        elif op.mnemonic == "sta":
            self.sta(op, arg)
        elif op.mnemonic == "stx":
            self.stx(op, arg)
        elif op.mnemonic == "sty":
            self.sty(op, arg)
        elif op.mnemonic == "ldx":
            self.ldx(op, arg)
        elif op.mnemonic == "ldy":
            self.ldy(op, arg)
        elif op.mnemonic == "lda":
            self.lda(op, arg)
        elif op.mnemonic == "cmp":
            self.cmp(op, arg)
        elif op.mnemonic == "bne":
            self.bne(op, arg)
        elif op.mnemonic == "inc":
            self.inc(op, arg)
        elif op.mnemonic == "inx":
            self.inx(op, arg)
        elif op.mnemonic == "dec":
            self.dec(op, arg)
        elif op.mnemonic == "nop":
            self.nop(op, arg)
        elif op.mnemonic == "beq":
            self.beq(op, arg)
        elif op.mnemonic == "bcc":
            self.bcc(op, arg)
        elif op.mnemonic == "eor":
            self.eor(op, arg)
        elif op.mnemonic == "sec":
            self.sec(op, arg)
        else:
            raise ValueError(f"unsupported instruction: {op.mnemonic}")

    def resolve_arg(self, op: Op, arg: int) -> int:
        if op.addressing == Addressing.ABSOLUTE:
            return self.memory.read_byte(arg)
        elif op.addressing == Addressing.ABSOLUTE_X:
            address = self.registers.X + arg
            return self.memory.read_byte(address)
        elif op.addressing == Addressing.IMMEDIATE:
            return arg
        elif op.addressing == Addressing.ZERO:
            return self.memory.read_byte(arg)
        elif op.addressing == Addressing.RELATIVE:
            return self.memory.read_byte(self.registers.PC + signed_byte(arg))
        elif op.addressing == Addressing.INDIRECT_INDEXED:
            low = self.memory.read_byte(arg)
            high = self.memory.read_byte((arg + 1) & 0xFF)
            base_address = (high << 8) | low
            address = (base_address + self.registers.Y) & 0xFFFF
            value = self.memory.read_byte(address)
            return value
        else:
            raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def set_n_by(self, value: int):
        if bool(value & 0x80):
            self.registers.set_p(CPU_STATUS.NEGATIVE)
        else:
            self.registers.clear_p(CPU_STATUS.NEGATIVE)

    def set_z_by(self, value: int):
        if value == 0:
            self.registers.set_p(CPU_STATUS.ZERO)
        else:
            self.registers.clear_p(CPU_STATUS.ZERO)

    def set_c_by(self, value: int):
        if value > 0xFF:
            self.registers.set_p(CPU_STATUS.CARRY)
        else:
            self.registers.clear_p(CPU_STATUS.CARRY)

    def set_v_by(self, value: int):
        if not (value >> 8) == 0:
            self.registers.set_p(CPU_STATUS.CARRY)
        else:
            self.registers.clear_p(CPU_STATUS.CARRY)

    def bpl(self, op: Op, arg: int):
        if not self.registers.is_p(CPU_STATUS.NEGATIVE):
            self.registers.PC += signed_byte(arg)

    def clc(self, op: Op, arg: int):
        self.registers.clear_p(CPU_STATUS.CARRY)

    def jsr(self, op: Op, arg: int):
        if op.addressing == Addressing.ABSOLUTE:
                value = self.registers.PC.to_bytes(length=2, byteorder="little")
                self.stack.push(value[0])
                self.stack.push(value[1])
                self.registers.PC = arg

    def and_(self, op: Op, arg: int):
        a = self.registers.A
        value = a & arg
        self.registers.A = value & 0xFF

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
        if op.addressing == Addressing.ABSOLUTE:
            self.registers.PC = arg
        else:
            raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def rts(self, op: Op, arg: int):
        low = self.stack.pull()
        high = self.stack.pull()
        self.registers.PC = int.from_bytes([high, low], byteorder='little')

    def pla(self, op: Op, arg: int):
        value = self.stack.pull()
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    def adc(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        carry = 1 if self.registers.is_p(CPU_STATUS.CARRY) else 0
        total = self.registers.A + value + carry
        self.registers.A = total & 0xFF

        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)
        self.set_c_by(total)
        # self.set_v_by(total)
        if ((self.registers.A ^ total) & (value ^ total) & 0x80) != 0:
            self.registers.set_p(CPU_STATUS.OVERFLOW)
        else:
            self.registers.clear_p(CPU_STATUS.OVERFLOW)

    def sei(self, op: Op, arg: int):
        self.registers.set_p(CPU_STATUS.INTERRUPT)

    def iny(self, op: Op, arg: int):
        self.registers.Y = (self.registers.Y + 1) & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    def dex(self, op: Op, arg: int):
        self.registers.X = (self.registers.X - 1) & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def dey(self, op: Op, arg: int):
        self.registers.Y = (self.registers.Y - 1) & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    def txa(self, op: Op, arg: int):
        self.registers.A = self.registers.X & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    def tya(self, op: Op, arg: int):
        self.registers.A = self.registers.Y & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    def tax(self, op: Op, arg: int):
        self.registers.X = self.registers.A & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def tay(self, op: Op, arg: int):
        self.registers.Y = self.registers.A & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    def sta(self, op: Op, arg: int):
        if op.addressing == Addressing.ABSOLUTE:
            self.memory.write_byte(arg, self.registers.A)
        elif op.addressing == Addressing.ZERO:
            self.memory.write_byte(arg, self.registers.A)
        else:
            raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def stx(self, op: Op, arg: int):
        if op.addressing == Addressing.ABSOLUTE:
            self.memory.write_byte(arg, self.registers.X)
        elif op.addressing == Addressing.ZERO:
            self.memory.write_byte(arg, self.registers.X)
        else:
            raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def sty(self, op: Op, arg: int):
        if op.addressing == Addressing.ABSOLUTE:
            self.memory.write_byte(arg, self.registers.Y)
        elif op.addressing == Addressing.ZERO:
            self.memory.write_byte(arg, self.registers.Y)
        else:
            raise ValueError(f"unsupported addressing mode: {op.addressing.name}")

    def ldx(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.X = value
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def ldy(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.Y = value & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    def lda(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        self.registers.A = value & 0xFF
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
        value = (self.resolve_arg(op, arg) + 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    def inx(self, op: Op, arg: int):
        self.registers.X = (self.registers.X + 1) & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    def dec(self, op: Op, arg: int):
        value = (self.resolve_arg(op, arg) - 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    def nop(self, op: Op, arg: int):
        ...

    def beq(self, op: Op, arg: int):
        if self.registers.is_p(CPU_STATUS.ZERO):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    def bcc(self, op: Op, arg: int):
        if not self.registers.is_p(CPU_STATUS.CARRY):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    def eor(self, op: Op, arg: int):
        value = self.resolve_arg(op, arg)
        result = self.registers.A ^ value
        self.registers.A = result
        self.set_n_by(result)
        self.set_z_by(result)

    def sec(self, op: Op, arg: int):
        self.registers.set_p(CPU_STATUS.CARRY)
