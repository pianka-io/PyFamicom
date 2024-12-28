from time import sleep

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

    cdef start(self):
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
                # print(f"interrupt ${self.memory.read_byte(0xA):x}")
                self.nmi.clear()
                self.stack.push(self.registers.PC >> 8)
                self.stack.push(self.registers.PC)
                self.stack.push(self.registers.P)
                self.registers.PC = self.memory.read_byte(NMI_VECTOR) | (self.memory.read_byte(NMI_VECTOR + 1) << 8)
                continue

            # regular operation
            opcode = self.memory.read_byte(self.registers.PC)

            self.registers.PC += 1
            self.handle_instruction(opcode)
            # self.print_registers()

    cdef stop(self):
        self.running = False

    cdef print_registers(self):
        print(f"P b{self.registers.P:08b} SP ${self.registers.SP:x} A ${self.registers.A:x} X ${self.registers.X:x} Y ${self.registers.Y:x}")

    cdef handle_instruction(self, int opcode):
        begin = self.registers.PC
        if opcode == 0x10:
            self.registers.PC += 1
            self.bpl_10(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0x18:
            self.clc_18()
            self.clock.cpu_cycles += 2
        elif opcode == 0x20:
            self.registers.PC += 2
            self.jsr_20(self.memory.read_word(begin))
            self.clock.cpu_cycles += 6
        elif opcode == 0x29:
            self.registers.PC += 1
            self.and_29(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0x2C:
            self.registers.PC += 2
            self.bit_2C(self.memory.read_word(begin))
            self.clock.cpu_cycles += 4
        elif opcode == 0x48:
            self.pha_48()
            self.clock.cpu_cycles += 3
        elif opcode == 0x40:
            self.rti_40()
            self.clock.cpu_cycles += 6
        elif opcode == 0x4C:
            self.registers.PC += 2
            self.jmp_4c(self.memory.read_word(begin))
            self.clock.cpu_cycles += 3
        elif opcode == 0x60:
            self.rts_60()
            self.clock.cpu_cycles += 6
        elif opcode == 0x68:
            self.pla_68()
            self.clock.cpu_cycles += 4
        elif opcode == 0x69:
            self.registers.PC += 1
            self.adc_69(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0x78:
            self.sei_78()
            self.clock.cpu_cycles += 2
        elif opcode == 0x88:
            self.dey_88()
            self.clock.cpu_cycles += 2
        elif opcode == 0x8A:
            self.txa_8a()
            self.clock.cpu_cycles += 2
        elif opcode == 0x8D:
            self.registers.PC += 2
            self.sta_8d(self.memory.read_word(begin))
            self.clock.cpu_cycles += 4
        elif opcode == 0x85:
            self.registers.PC += 1
            self.sta_85(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 3
        elif opcode == 0x86:
            self.registers.PC += 1
            self.stx_86(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 3
        elif opcode == 0x8E:
            self.registers.PC += 2
            self.stx_8e(self.memory.read_word(begin))
            self.clock.cpu_cycles += 4
        elif opcode == 0x84:
            self.registers.PC += 1
            self.sty_84(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 3
        elif opcode == 0x90:
            self.registers.PC += 1
            self.bcc_90(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0x98:
            self.tya_98()
            self.clock.cpu_cycles += 2
        elif opcode == 0xA2:
            self.registers.PC += 1
            self.ldx_a2(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0xA0:
            self.registers.PC += 1
            self.ldy_a0(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0xA8:
            self.tay_a8()
            self.clock.cpu_cycles += 2
        elif opcode == 0xAA:
            self.tax_aa()
            self.clock.cpu_cycles += 2
        elif opcode == 0xA5:
            self.registers.PC += 1
            self.lda_a5(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 3
        elif opcode == 0xA9:
            self.registers.PC += 1
            self.lda_a9(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0xAD:
            self.registers.PC += 2
            self.lda_ad(self.memory.read_word(begin))
            self.clock.cpu_cycles += 4
        elif opcode == 0xB1:
            self.registers.PC += 1
            self.lda_b1(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 5
        elif opcode == 0xBD:
            self.registers.PC += 2
            self.lda_bd(self.memory.read_word(begin))
            self.clock.cpu_cycles += 4
        elif opcode == 0xC5:
            self.registers.PC += 1
            self.cmp_c5(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 3
        elif opcode == 0xC9:
            self.registers.PC += 1
            self.cmp_c9(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0xC8:
            self.iny_c8()
            self.clock.cpu_cycles += 2
        elif opcode == 0xCA:
            self.dex_ca()
            self.clock.cpu_cycles += 2
        elif opcode == 0xCD:
            self.registers.PC += 2
            self.cmp_cd(self.memory.read_word(begin))
            self.clock.cpu_cycles += 4
        elif opcode == 0xD0:
            self.registers.PC += 1
            self.bne_d0(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0xE6:
            self.registers.PC += 1
            self.inc_e6(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 5
        elif opcode == 0xE8:
            self.inx_e8()
            self.clock.cpu_cycles += 2
        elif opcode == 0xEE:
            self.registers.PC += 2
            self.inc_ee(self.memory.read_word(begin))
            self.clock.cpu_cycles += 6
        elif opcode == 0xC6:
            self.registers.PC += 1
            self.dec_c6(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 5
        elif opcode == 0xEA:
            self.nop_ea()
            self.clock.cpu_cycles += 2
        elif opcode == 0xF0:
            self.registers.PC += 1
            self.beq_f0(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0x49:
            self.registers.PC += 1
            self.eor_49(self.memory.read_byte(begin))
            self.clock.cpu_cycles += 2
        elif opcode == 0x38:
            self.sec_38()
            self.clock.cpu_cycles += 2
        else:
            raise ValueError(f"unsupported instruction: ${opcode:x}")

    cdef set_n_by(self, int value):
        if bool(value & 0x80):
            self.registers.set_p(CPU_STATUS_NEGATIVE)
        else:
            self.registers.clear_p(CPU_STATUS_NEGATIVE)

    cdef set_z_by(self, int value):
        if value == 0:
            self.registers.set_p(CPU_STATUS_ZERO)
        else:
            self.registers.clear_p(CPU_STATUS_ZERO)

    cdef set_c_by(self, int value):
        if value > 0xFF:
            self.registers.set_p(CPU_STATUS_CARRY)
        else:
            self.registers.clear_p(CPU_STATUS_CARRY)

    cdef set_v_by(self, int value):
        if not (value >> 8) == 0:
            self.registers.set_p(CPU_STATUS_CARRY)
        else:
            self.registers.clear_p(CPU_STATUS_CARRY)

    cdef bpl_10(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] bpl ${arg:X}")
        if not self.registers.is_p(CPU_STATUS_NEGATIVE):
            self.registers.PC += signed_byte(arg)

    cdef clc_18(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] clc")
        self.registers.clear_p(CPU_STATUS_CARRY)

    cdef jsr_20(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] jsr ${arg:X}")
        value = self.registers.PC.to_bytes(length=2, byteorder="little")
        self.stack.push(value[0])
        self.stack.push(value[1])
        self.registers.PC = arg

    cdef and_29(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] and ${arg:X}")
        a = self.registers.A
        value = a & arg
        self.registers.A = value & 0xFF

        self.set_n_by(value)
        self.set_z_by(value)

    cdef bit_2C(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] bit ${arg:X}")
        value = self.memory.read_byte(arg)

        # M7 -> N, M6 -> V
        nv = value & 0b11000000
        self.registers.clear_p(CPU_STATUS_NEGATIVE)
        self.registers.clear_p(CPU_STATUS_OVERFLOW)
        p = self.registers.P | nv
        self.registers.P = p

        # A AND M -> Z
        result = self.registers.A & value
        if result == 0:
            self.registers.set_p(CPU_STATUS_ZERO)
        else:
            self.registers.clear_p(CPU_STATUS_ZERO)

    cdef pha_48(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] pha")
        self.stack.push(self.registers.A)

    cdef rti_40(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] rti")
        self.registers.P = self.stack.pull()
        low = self.stack.pull()
        high = self.stack.pull()
        self.registers.PC = (high << 8) | low

    cdef jmp_4c(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] jmp ${arg:X}")
        self.registers.PC = arg

    cdef rts_60(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] rts")
        low = self.stack.pull()
        high = self.stack.pull()
        self.registers.PC = int.from_bytes([high, low], byteorder='little')

    cdef pla_68(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] pla")
        value = self.stack.pull()
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef adc_69(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] adc ${arg:X}")
        value = self.memory.read_byte(arg)
        carry = 1 if self.registers.is_p(CPU_STATUS_CARRY) else 0
        total = self.registers.A + value + carry
        self.registers.A = total & 0xFF

        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)
        self.set_c_by(total)
        # self.set_v_by(total)
        if ((self.registers.A ^ total) & (value ^ total) & 0x80) != 0:
            self.registers.set_p(CPU_STATUS_OVERFLOW)
        else:
            self.registers.clear_p(CPU_STATUS_OVERFLOW)

    cdef sei_78(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] sei")
        self.registers.set_p(CPU_STATUS_INTERRUPT)

    cdef iny_c8(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] iny")
        self.registers.Y = (self.registers.Y + 1) & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef dex_ca(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] dex")
        self.registers.X = (self.registers.X - 1) & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef dey_88(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] dey")
        self.registers.Y = (self.registers.Y - 1) & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef txa_8a(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] lxa")
        self.registers.A = self.registers.X & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef tya_98(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] tya")
        self.registers.A = self.registers.Y & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef tax_aa(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] tax")
        self.registers.X = self.registers.A & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef tay_a8(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] tay")
        self.registers.Y = self.registers.A & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef sta_8d(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] sta ${arg:X}")
        self.memory.write_byte(arg, self.registers.A)

    cdef sta_85(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] sta ${arg:X}")
        self.memory.write_byte(arg, self.registers.A)

    cdef stx_86(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] stx ${arg:X}")
        self.memory.write_byte(arg, self.registers.X)

    cdef stx_8e(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] stx ${arg:X}")
        self.memory.write_byte(arg, self.registers.X)

    cdef sty_84(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] stx ${arg:X}")
        self.memory.write_byte(arg, self.registers.Y)

    cdef ldx_a2(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] ldx ${arg:X}")
        self.registers.X = arg & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef ldy_a0(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] ldy ${arg:X}")
        self.registers.Y = arg & 0xFF
        self.set_n_by(self.registers.Y)
        self.set_z_by(self.registers.Y)

    cdef lda_a5(self, int arg):  # zero
        if self.logging:
            print(f"[${self.registers.PC:x}] lda ${arg:X}")
        value = self.memory.read_byte(arg)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef lda_a9(self, int arg):  # immediate
        if self.logging:
            print(f"[${self.registers.PC:x}] lda ${arg:X}")
        self.registers.A = arg & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef lda_ad(self, int arg):  # absolute
        if self.logging:
            print(f"[${self.registers.PC:x}] lda ${arg:X}")
        value = self.memory.read_byte(arg)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef lda_b1(self, int arg):  # indirect indexed
        if self.logging:
            print(f"[${self.registers.PC:x}] lda ${arg:X}")
        low = self.memory.read_byte(arg)
        high = self.memory.read_byte((arg + 1) & 0xFF)
        base_address = (high << 8) | low
        address = (base_address + self.registers.Y) & 0xFFFF
        value = self.memory.read_byte(address)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef lda_bd(self, int arg):  # absolute x
        if self.logging:
            print(f"[${self.registers.PC:x}] lda ${arg:X}")
        address = self.registers.X + arg
        value = self.memory.read_byte(address)
        self.registers.A = value & 0xFF
        self.set_n_by(self.registers.A)
        self.set_z_by(self.registers.A)

    cdef cmp_c5(self, int arg):  # zero
        if self.logging:
            print(f"[${self.registers.PC:x}] cmp_c5 ${arg:X}")
        value = self.memory.read_byte(arg)
        result = self.registers.A - value
        result = signed_byte(result)

        self.set_n_by(result)
        self.set_z_by(result)
        self.set_c_by(result)

    cdef cmp_c9(self, int arg):  # immediate
        if self.logging:
            print(f"[${self.registers.PC:x}] cmp_c9 ${arg:X}")
        result = self.registers.A - arg
        result = signed_byte(result)

        self.set_n_by(result)
        self.set_z_by(result)
        self.set_c_by(result)

    cdef cmp_cd(self, int arg):  # absolute
        if self.logging:
            print(f"[${self.registers.PC:x}] cmp_cd ${arg:X}")
        value = self.memory.read_byte(arg)
        result = self.registers.A - value
        result = signed_byte(result)

        self.set_n_by(result)
        self.set_z_by(result)
        self.set_c_by(result)

    cdef bne_d0(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] bne ${arg:X}")
        if not self.registers.is_p(CPU_STATUS_ZERO):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    cdef inc_e6(self, int arg):  # zero
        if self.logging:
            print(f"[${self.registers.PC:x}] inc_e6 ${arg:X}")
        value = (self.memory.read_byte(arg) + 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    cdef inc_ee(self, int arg):  # absolute
        if self.logging:
            print(f"[${self.registers.PC:x}] inc_ee ${arg:X}")
        value = (self.memory.read_byte(arg) + 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    cdef inx_e8(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] inx")
        self.registers.X = (self.registers.X + 1) & 0xFF
        self.set_n_by(self.registers.X)
        self.set_z_by(self.registers.X)

    cdef dec_c6(self, int arg):  # zero
        if self.logging:
            print(f"[${self.registers.PC:x}] dec ${arg:X}")
        value = (self.memory.read_byte(arg) - 1) & 0xFF
        self.memory.write_byte(arg, value)
        self.set_n_by(value)
        self.set_z_by(value)

    cdef nop_ea(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] nop")
        ...

    cdef beq_f0(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] beq ${arg:X}")
        if self.registers.is_p(CPU_STATUS_ZERO):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    cdef bcc_90(self, int arg):
        if self.logging:
            print(f"[${self.registers.PC:x}] bcc ${arg:X}")
        if not self.registers.is_p(CPU_STATUS_CARRY):
            self.registers.PC = self.registers.PC + signed_byte(arg)

    cdef eor_49(self, int arg):  # immediate
        if self.logging:
            print(f"[${self.registers.PC:x}] eor ${arg:X}")
        result = self.registers.A ^ arg
        self.registers.A = result
        self.set_n_by(result)
        self.set_z_by(result)

    cdef sec_38(self):
        if self.logging:
            print(f"[${self.registers.PC:x}] sec")
        self.registers.set_p(CPU_STATUS_CARRY)
