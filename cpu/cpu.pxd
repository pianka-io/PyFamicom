from com.clock cimport Clock
from com.interrupt cimport Interrupt
from cpu.memory cimport Memory
from cpu.registers cimport Registers
from cpu.stack cimport Stack
from ppu.ppu cimport PPU


cdef class CPU:
    cdef Clock clock
    cdef PPU ppu
    cdef Interrupt nmi
    cdef Registers registers
    cdef Memory memory
    cdef Stack stack
    cdef int entry

    cdef void tick(self) noexcept nogil
    cdef inline void track_cycles(self, int cycles) noexcept nogil
    cdef inline void advance_pc(self, int offset) noexcept nogil
    cdef inline void handle_instruction(self, int opcode) noexcept nogil
    cdef inline void set_n_by(self, int value) noexcept nogil
    cdef inline void set_z_by(self, int value) noexcept nogil
    cdef inline void set_c_by(self, int value) noexcept nogil
    cdef inline void set_v_by(self, int value) noexcept nogil
    cdef inline void bpl_10(self, int arg) noexcept nogil
    cdef inline void clc_18(self) noexcept nogil
    cdef inline void jsr_20(self, int arg) noexcept nogil
    cdef inline void and_29(self, int arg) noexcept nogil
    cdef inline void bit_2C(self, int arg) noexcept nogil
    cdef inline void pha_48(self) noexcept nogil
    cdef inline void rti_40(self) noexcept nogil
    cdef inline void jmp_4c(self, int arg) noexcept nogil
    cdef inline void rts_60(self) noexcept nogil
    cdef inline void pla_68(self) noexcept nogil
    cdef inline void adc_69(self, int arg) noexcept nogil
    cdef inline void sei_78(self) noexcept nogil
    cdef inline void iny_c8(self) noexcept nogil
    cdef inline void dex_ca(self) noexcept nogil
    cdef inline void dey_88(self) noexcept nogil
    cdef inline void txa_8a(self) noexcept nogil
    cdef inline void tya_98(self) noexcept nogil
    cdef inline void tax_aa(self) noexcept nogil
    cdef inline void tay_a8(self) noexcept nogil
    cdef inline void sta_8d(self, int arg) noexcept nogil
    cdef inline void sta_85(self, int arg) noexcept nogil
    cdef inline void stx_86(self, int arg) noexcept nogil
    cdef inline void stx_8e(self, int arg) noexcept nogil
    cdef inline void sty_84(self, int arg) noexcept nogil
    cdef inline void ldx_a2(self, int arg) noexcept nogil
    cdef inline void ldy_a0(self, int arg) noexcept nogil
    cdef inline void lda_a5(self, int arg) noexcept nogil
    cdef inline void lda_a9(self, int arg) noexcept nogil
    cdef inline void lda_ad(self, int arg) noexcept nogil
    cdef inline void lda_b1(self, int arg) noexcept nogil
    cdef inline void lda_bd(self, int arg) noexcept nogil
    cdef inline void cmp_c5(self, int arg) noexcept nogil
    cdef inline void cmp_c9(self, int arg) noexcept nogil
    cdef inline void cmp_cd(self, int arg) noexcept nogil
    cdef inline void bne_d0(self, int arg) noexcept nogil
    cdef inline void inc_e6(self, int arg) noexcept nogil
    cdef inline void inc_ee(self, int arg) noexcept nogil
    cdef inline void inx_e8(self) noexcept nogil
    cdef inline void dec_c6(self, int arg) noexcept nogil
    cdef inline void nop_ea(self) noexcept nogil
    cdef inline void beq_f0(self, int arg) noexcept nogil
    cdef inline void bcc_90(self, int arg) noexcept nogil
    cdef inline void eor_49(self, int arg) noexcept nogil
    cdef inline void sec_38(self) noexcept nogil
