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
    cdef int timer

    cdef void tick(self) nogil
    cdef void track_cycles(self, int cycles) nogil
    cdef void advance_pc(self, int offset) nogil
    # cdef void print_registers(self) nogil
    cdef void handle_instruction(self, int opcode) nogil
    cdef void set_n_by(self, int value) nogil
    cdef void set_z_by(self, int value) nogil
    cdef void set_c_by(self, int value) nogil
    cdef void set_v_by(self, int value) nogil
    cdef void bpl_10(self, int arg) nogil
    cdef void clc_18(self) nogil
    cdef void jsr_20(self, int arg) nogil
    cdef void and_29(self, int arg) nogil
    cdef void bit_2C(self, int arg) nogil
    cdef void pha_48(self) nogil
    cdef void rti_40(self) nogil
    cdef void jmp_4c(self, int arg) nogil
    cdef void rts_60(self) nogil
    cdef void pla_68(self) nogil
    cdef void adc_69(self, int arg) nogil
    cdef void sei_78(self) nogil
    cdef void iny_c8(self) nogil
    cdef void dex_ca(self) nogil
    cdef void dey_88(self) nogil
    cdef void txa_8a(self) nogil
    cdef void tya_98(self) nogil
    cdef void tax_aa(self) nogil
    cdef void tay_a8(self) nogil
    cdef void sta_8d(self, int arg) nogil
    cdef void sta_85(self, int arg) nogil
    cdef void stx_86(self, int arg) nogil
    cdef void stx_8e(self, int arg) nogil
    cdef void sty_84(self, int arg) nogil
    cdef void ldx_a2(self, int arg) nogil
    cdef void ldy_a0(self, int arg) nogil
    cdef void lda_a5(self, int arg) nogil
    cdef void lda_a9(self, int arg) nogil
    cdef void lda_ad(self, int arg) nogil
    cdef void lda_b1(self, int arg) nogil
    cdef void lda_bd(self, int arg) nogil
    cdef void cmp_c5(self, int arg) nogil
    cdef void cmp_c9(self, int arg) nogil
    cdef void cmp_cd(self, int arg) nogil
    cdef void bne_d0(self, int arg) nogil
    cdef void inc_e6(self, int arg) nogil
    cdef void inc_ee(self, int arg) nogil
    cdef void inx_e8(self) nogil
    cdef void dec_c6(self, int arg) nogil
    cdef void nop_ea(self) nogil
    cdef void beq_f0(self, int arg) nogil
    cdef void bcc_90(self, int arg) nogil
    cdef void eor_49(self, int arg) nogil
    cdef void sec_38(self) nogil
