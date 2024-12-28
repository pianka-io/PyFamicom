from com.clock cimport Clock
from com.interrupt cimport Interrupt
from cpu.memory cimport Memory
from cpu.registers cimport Registers
from cpu.stack cimport Stack
from ppu.ppu cimport PPU


cdef class CPU:
    cdef bint logging
    cdef bint running
    cdef Clock clock
    cdef PPU ppu
    cdef Interrupt nmi
    cdef Registers registers
    cdef Memory memory
    cdef Stack stack
    cdef int entry

    cdef start(self)
    cdef stop(self)
    cdef print_registers(self)
    cdef handle_instruction(self, int opcode)
    cdef set_n_by(self, int value)
    cdef set_z_by(self, int value)
    cdef set_c_by(self, int value)
    cdef set_v_by(self, int value)
    cdef bpl_10(self, int arg)
    cdef clc_18(self)
    cdef jsr_20(self, int arg)
    cdef and_29(self, int arg)
    cdef bit_2C(self, int arg)
    cdef pha_48(self)
    cdef rti_40(self)
    cdef jmp_4c(self, int arg)
    cdef rts_60(self)
    cdef pla_68(self)
    cdef adc_69(self, int arg)
    cdef sei_78(self)
    cdef iny_c8(self)
    cdef dex_ca(self)
    cdef dey_88(self)
    cdef txa_8a(self)
    cdef tya_98(self)
    cdef tax_aa(self)
    cdef tay_a8(self)
    cdef sta_8d(self, int arg)
    cdef sta_85(self, int arg)
    cdef stx_86(self, int arg)
    cdef stx_8e(self, int arg)
    cdef sty_84(self, int arg)
    cdef ldx_a2(self, int arg)
    cdef ldy_a0(self, int arg)
    cdef lda_a5(self, int arg)
    cdef lda_a9(self, int arg)
    cdef lda_ad(self, int arg)
    cdef lda_b1(self, int arg)
    cdef lda_bd(self, int arg)
    cdef cmp_c5(self, int arg)
    cdef cmp_c9(self, int arg)
    cdef cmp_cd(self, int arg)
    cdef bne_d0(self, int arg)
    cdef inc_e6(self, int arg)
    cdef inc_ee(self, int arg)
    cdef inx_e8(self)
    cdef dec_c6(self, int arg)
    cdef nop_ea(self)
    cdef beq_f0(self, int arg)
    cdef bcc_90(self, int arg)
    cdef eor_49(self, int arg)
    cdef sec_38(self)
