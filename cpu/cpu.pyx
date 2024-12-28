import time

from com.clock cimport Clock
from com.constants cimport RESET_VECTOR, NMI_VECTOR, CPU_STATUS_NEGATIVE, CPU_STATUS_ZERO, CPU_STATUS_CARRY, \
    CPU_STATUS_OVERFLOW, CPU_STATUS_INTERRUPT
from com.interrupt cimport Interrupt
from com.utilities cimport signed_byte
from cpu.memory cimport Memory
from cpu.registers cimport Registers
from cpu.stack cimport Stack
from ppu.ppu cimport PPU


cdef class CPU:
    def __init__(self, clock: Clock, ppu: PPU, nmi: Interrupt, prg_rom: bytes):
        self.logging = False
        self.running = False
        self.clock = clock
        self.ppu = ppu
        self.nmi = nmi

        self.registers = Registers()
        self.memory = Memory(self.ppu, prg_rom)
        self.stack = Stack(self.registers, self.memory)

        self.entry = self.memory.read_word(RESET_VECTOR)
        self.registers.PC = self.entry
        self.timer = time.perf_counter()

    cdef void tick(self) nogil:
        # with gil:
        #     print(f"cpu {self.clock.cpu_cycles}")
        # self.pause(0)
        cdef int delta
        with gil:
            delta = time.perf_counter() - self.timer
            if delta > 1.0:
                self.timer = time.perf_counter()
                print(self.clock.cpu_cycles)

        # ppu nmi interrupt
        if self.nmi.active():
            self.nmi.clear()
            self.stack.push(self.registers.PC >> 8)
            self.stack.push(self.registers.PC)
            self.stack.push(self.registers.P)
            self.registers.PC = self.memory.read_byte(NMI_VECTOR) | (self.memory.read_byte(NMI_VECTOR + 1) << 8)
            return

        # regular operation
        opcode = self.memory.read_byte(self.registers.PC)

        self.advance_pc(1)
        self.handle_instruction(opcode)
        # self.print_registers()
            
    cdef void track_cycles(self, int cycles) nogil:
        cdef int value = self.clock.cpu_cycles + cycles
        self.clock.cpu_cycles = value
            
    cdef void advance_pc(self, int offset) nogil:
        cdef int value = self.registers.PC + offset
        self.registers.PC = value

    # cdef print_registers(self) nogil:
    #     print(f"P b{self.registers.P:08b} SP ${self.registers.SP:x} A ${self.registers.A:x} X ${self.registers.X:x} Y ${self.registers.Y:x}")

    cdef void handle_instruction(self, int opcode) nogil:
        begin = self.registers.PC
        if opcode == 0x10:
            self.advance_pc(1)
            self.bpl_10(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0x18:
            self.clc_18()
            self.track_cycles(2)
        elif opcode == 0x20:
            self.advance_pc(2)
            self.jsr_20(self.memory.read_word(begin))
            self.track_cycles(6)
        elif opcode == 0x29:
            self.advance_pc(1)
            self.and_29(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0x2C:
            self.advance_pc(2)
            self.bit_2C(self.memory.read_word(begin))
            self.track_cycles(4)
        elif opcode == 0x48:
            self.pha_48()
            self.track_cycles(3)
        elif opcode == 0x40:
            self.rti_40()
            self.track_cycles(6)
        elif opcode == 0x4C:
            self.advance_pc(2)
            self.jmp_4c(self.memory.read_word(begin))
            self.track_cycles(3)
        elif opcode == 0x60:
            self.rts_60()
            self.track_cycles(6)
        elif opcode == 0x68:
            self.pla_68()
            self.track_cycles(4)
        elif opcode == 0x69:
            self.advance_pc(1)
            self.adc_69(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0x78:
            self.sei_78()
            self.track_cycles(2)
        elif opcode == 0x88:
            self.dey_88()
            self.track_cycles(2)
        elif opcode == 0x8A:
            self.txa_8a()
            self.track_cycles(2)
        elif opcode == 0x8D:
            self.advance_pc(2)
            self.sta_8d(self.memory.read_word(begin))
            self.track_cycles(4)
        elif opcode == 0x85:
            self.advance_pc(1)
            self.sta_85(self.memory.read_byte(begin))
            self.track_cycles(3)
        elif opcode == 0x86:
            self.advance_pc(1)
            self.stx_86(self.memory.read_byte(begin))
            self.track_cycles(3)
        elif opcode == 0x8E:
            self.advance_pc(2)
            self.stx_8e(self.memory.read_word(begin))
            self.track_cycles(4)
        elif opcode == 0x84:
            self.advance_pc(1)
            self.sty_84(self.memory.read_byte(begin))
            self.track_cycles(3)
        elif opcode == 0x90:
            self.advance_pc(1)
            self.bcc_90(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0x98:
            self.tya_98()
            self.track_cycles(2)
        elif opcode == 0xA2:
            self.advance_pc(1)
            self.ldx_a2(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0xA0:
            self.advance_pc(1)
            self.ldy_a0(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0xA8:
            self.tay_a8()
            self.track_cycles(2)
        elif opcode == 0xAA:
            self.tax_aa()
            self.track_cycles(2)
        elif opcode == 0xA5:
            self.advance_pc(1)
            self.lda_a5(self.memory.read_byte(begin))
            self.track_cycles(3)
        elif opcode == 0xA9:
            self.advance_pc(1)
            self.lda_a9(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0xAD:
            self.advance_pc(2)
            self.lda_ad(self.memory.read_word(begin))
            self.track_cycles(4)
        elif opcode == 0xB1:
            self.advance_pc(1)
            self.lda_b1(self.memory.read_byte(begin))
            self.track_cycles(5)
        elif opcode == 0xBD:
            self.advance_pc(2)
            self.lda_bd(self.memory.read_word(begin))
            self.track_cycles(4)
        elif opcode == 0xC5:
            self.advance_pc(1)
            self.cmp_c5(self.memory.read_byte(begin))
            self.track_cycles(3)
        elif opcode == 0xC9:
            self.advance_pc(1)
            self.cmp_c9(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0xC8:
            self.iny_c8()
            self.track_cycles(2)
        elif opcode == 0xCA:
            self.dex_ca()
            self.track_cycles(2)
        elif opcode == 0xCD:
            self.advance_pc(2)
            self.cmp_cd(self.memory.read_word(begin))
            self.track_cycles(4)
        elif opcode == 0xD0:
            self.advance_pc(1)
            self.bne_d0(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0xE6:
            self.advance_pc(1)
            self.inc_e6(self.memory.read_byte(begin))
            self.track_cycles(5)
        elif opcode == 0xE8:
            self.inx_e8()
            self.track_cycles(2)
        elif opcode == 0xEE:
            self.advance_pc(2)
            self.inc_ee(self.memory.read_word(begin))
            self.track_cycles(6)
        elif opcode == 0xC6:
            self.advance_pc(1)
            self.dec_c6(self.memory.read_byte(begin))
            self.track_cycles(5)
        elif opcode == 0xEA:
            self.nop_ea()
            self.track_cycles(2)
        elif opcode == 0xF0:
            self.advance_pc(1)
            self.beq_f0(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0x49:
            self.advance_pc(1)
            self.eor_49(self.memory.read_byte(begin))
            self.track_cycles(2)
        elif opcode == 0x38:
            self.sec_38()
            self.track_cycles(2)
        else:
            raise ValueError(f"unsupported instruction: ${opcode:x}")

    cdef void set_n_by(self, int value) nogil:
        if value & 0x80:
            self.registers.set_p(CPU_STATUS_NEGATIVE)
        else:
            self.registers.clear_p(CPU_STATUS_NEGATIVE)

    cdef void set_z_by(self, int value) nogil:
        if value == 0:
            self.registers.set_p(CPU_STATUS_ZERO)
        else:
            self.registers.clear_p(CPU_STATUS_ZERO)

    cdef void set_c_by(self, int value) nogil:
        if value > 0xFF:
            self.registers.set_p(CPU_STATUS_CARRY)
        else:
            self.registers.clear_p(CPU_STATUS_CARRY)

    cdef void set_v_by(self, int value) nogil:
        if not (value >> 8) == 0:
            self.registers.set_p(CPU_STATUS_CARRY)
        else:
            self.registers.clear_p(CPU_STATUS_CARRY)

    cdef void bpl_10(self, int arg) nogil:
        cdef int value
        if not self.registers.is_p(CPU_STATUS_NEGATIVE):
            value = self.registers.PC + signed_byte(arg)
            self.registers.PC = value

    cdef void clc_18(self) nogil:
        self.registers.clear_p(CPU_STATUS_CARRY)

    cdef void jsr_20(self, int arg) nogil:
        cdef unsigned char low_byte, high_byte
        low_byte = <unsigned char> (self.registers.PC & 0xFF)
        high_byte = <unsigned char> ((self.registers.PC >> 8) & 0xFF)

        self.stack.push(low_byte)
        self.stack.push(high_byte)
        self.registers.PC = arg

    cdef void and_29(self, int arg) nogil:
        cdef int a = self.registers.A
        cdef int value = a & arg
        self.registers.A = value & 0xFF

        self.set_n_by(value)
        self.set_z_by(value)

    cdef void bit_2C(self, int arg) nogil:
        cdef int value = self.memory.read_byte(arg)

        # M7 -> N, M6 -> V
        cdef int nv = value & 0b11000000
        self.registers.clear_p(CPU_STATUS_NEGATIVE)
        self.registers.clear_p(CPU_STATUS_OVERFLOW)
        cdef int p = self.registers.P | nv
        self.registers.P = p

        # A AND M -> Z
        cdef int result = self.registers.A & value
        if result == 0:
            self.registers.set_p(CPU_STATUS_ZERO)
        else:
            self.registers.clear_p(CPU_STATUS_ZERO)

    cdef void pha_48(self) nogil:
        self.stack.push(self.registers.A)

    cdef void rti_40(self) nogil:
        self.registers.P = self.stack.pull()
        cdef int low = self.stack.pull()
        cdef int high = self.stack.pull()
        self.registers.PC = (high << 8) | low

    cdef void jmp_4c(self, int arg) nogil:
        self.registers.PC = arg

    cdef void rts_60(self) nogil:
        cdef unsigned char high = self.stack.pull()
        cdef unsigned char low = self.stack.pull()
        self.registers.PC = (<int> high << 8) | <int> low

    cdef void pla_68(self) nogil:
        cdef int value = self.stack.pull()
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void adc_69(self, int arg) nogil:
        cdef int value = self.memory.read_byte(arg)
        cdef int carry = 1 if self.registers.is_p(CPU_STATUS_CARRY) else 0
        cdef int total = self.registers.A + value + carry
        self.registers.A = total & 0xFF

        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)
        self.set_c_by(total)
        # self.set_v_by(total)
        if ((self.registers.A ^ total) & (value ^ total) & 0x80) != 0:
            self.registers.set_p(CPU_STATUS_OVERFLOW)
        else:
            self.registers.clear_p(CPU_STATUS_OVERFLOW)

    cdef void sei_78(self) nogil:
        self.registers.set_p(CPU_STATUS_INTERRUPT)

    cdef void iny_c8(self) nogil:
        self.registers.Y = (self.registers.Y + 1) & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef void dex_ca(self) nogil:
        self.registers.X = (self.registers.X - 1) & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef void dey_88(self) nogil:
        self.registers.Y = (self.registers.Y - 1) & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef void txa_8a(self) nogil:
        self.registers.A = self.registers.X & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void tya_98(self) nogil:
        self.registers.A = self.registers.Y & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void tax_aa(self) nogil:
        self.registers.X = self.registers.A & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef void tay_a8(self) nogil:
        self.registers.Y = self.registers.A & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef void sta_8d(self, int arg) nogil:
        self.memory.write_byte(arg, self.registers.A)

    cdef void sta_85(self, int arg) nogil:
        self.memory.write_byte(arg, self.registers.A)

    cdef void stx_86(self, int arg) nogil:
        self.memory.write_byte(arg, self.registers.X)

    cdef void stx_8e(self, int arg) nogil:
        self.memory.write_byte(arg, self.registers.X)

    cdef void sty_84(self, int arg) nogil:
        self.memory.write_byte(arg, self.registers.Y)

    cdef void ldx_a2(self, int arg) nogil:
        self.registers.X = arg & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef void ldy_a0(self, int arg) nogil:
        self.registers.Y = arg & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef void lda_a5(self, int arg) nogil:  # zero
        value = self.memory.read_byte(arg)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void lda_a9(self, int arg) nogil:  # immediate
        self.registers.A = arg & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void lda_ad(self, int arg) nogil:  # absolute
        value = self.memory.read_byte(arg)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void lda_b1(self, int arg) nogil:  # indirect indexed
        cdef int low = self.memory.read_byte(arg)
        cdef int high = self.memory.read_byte((arg + 1) & 0xFF)
        cdef int base_address = (high << 8) | low
        cdef int address = (base_address + self.registers.Y) & 0xFFFF
        cdef int value = self.memory.read_byte(address)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void lda_bd(self, int arg) nogil:  # absolute x
        cdef int address = self.registers.X + arg
        cdef int value = self.memory.read_byte(address)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef void cmp_c5(self, int arg) nogil:  # zero
        cdef int value = self.memory.read_byte(arg)
        cdef int result = self.registers.A - value
        result = signed_byte(result)

        self.set_n_by(result)
        self.set_z_by(result)
        self.set_c_by(result)

    cdef void cmp_c9(self, int arg) nogil:  # immediate
        cdef int result = self.registers.A - arg
        result = signed_byte(result)

        self.set_n_by(result)
        self.set_z_by(result)
        self.set_c_by(result)

    cdef void cmp_cd(self, int arg) nogil:  # absolute
        cdef int value = self.memory.read_byte(arg)
        cdef int result = self.registers.A - value
        result = signed_byte(result)

        self.set_n_by(result)
        self.set_z_by(result)
        self.set_c_by(result)

    cdef void bne_d0(self, int arg) nogil:
        if not self.registers.is_p(CPU_STATUS_ZERO):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    cdef void inc_e6(self, int arg) nogil:  # zero
        cdef int value = (self.memory.read_byte(arg) + 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    cdef void inc_ee(self, int arg) nogil:  # absolute
        cdef int value = (self.memory.read_byte(arg) + 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    cdef void inx_e8(self) nogil:
        self.registers.X = (self.registers.X + 1) & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef void dec_c6(self, int arg) nogil:  # zero
        cdef int value = (self.memory.read_byte(arg) - 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    cdef void nop_ea(self) nogil:
        ...

    cdef void beq_f0(self, int arg) nogil:
        if self.registers.is_p(CPU_STATUS_ZERO):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    cdef void bcc_90(self, int arg) nogil:
        if not self.registers.is_p(CPU_STATUS_CARRY):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    cdef void eor_49(self, int arg) nogil:  # immediate
        cdef int result = self.registers.A ^ arg
        self.registers.A = result
        self.set_n_by(result)
        self.set_z_by(result)

    cdef void sec_38(self) nogil:
        self.registers.set_p(CPU_STATUS_CARRY)
