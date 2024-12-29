# cython: profile=True
# cython: linetrace=True

from com.constants cimport PRG_OFFSET, PRG_BANK_SIZE, HEADER_SIZE, CPU_MEMORY_SIZE, PPU_REGISTER_OAMDMA, \
    PPU_REGISTER_PPUCTRL
from ppu.ppu cimport PPU


cdef class Memory:
    def __init__(self, ppu: PPU, prg_rom: bytes):
        self.ppu = ppu
        # self.memory = bytearray(CPU_MEMORY_SIZE)
        self.memory[PRG_OFFSET:CPU_MEMORY_SIZE] = prg_rom
        self.mirrored = len(prg_rom) <= PRG_BANK_SIZE

    cdef int read_byte(self, int address) noexcept nogil:
        if PPU_REGISTER_PPUCTRL <= address <= PPU_REGISTER_OAMDMA:
            return self.ppu.registers.read_byte(address)
        translated = self.translate_address(address)
        return self.memory[translated]

    cdef int read_word(self, int address) noexcept nogil:
        cdef int translated = self.translate_address(address)
        cdef unsigned char low_byte, high_byte

        low_byte = self.memory[translated]
        high_byte = self.memory[translated + 1]

        return (<int> high_byte << 8) | <int> low_byte

    cdef void write_byte(self, int address, int value) noexcept nogil:
        if PPU_REGISTER_PPUCTRL <= address <= PPU_REGISTER_OAMDMA:
            self.ppu.registers.write_byte(address, value)
            return
        translated = self.translate_address(address)
        self.memory[translated] = value & 0xFF

    cdef inline int translate_address(self, int address) noexcept nogil:
        if self.mirrored and address > PRG_OFFSET + PRG_BANK_SIZE:
            return address - PRG_BANK_SIZE
        else:
            return address

    cdef inline int translate_cpu_address_to_rom(self, int address) noexcept nogil:
        cdef int onset = address - PRG_OFFSET
        if self.mirrored and onset > PRG_BANK_SIZE:
            onset -= PRG_BANK_SIZE
        return onset + HEADER_SIZE
