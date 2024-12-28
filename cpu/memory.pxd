from ppu.ppu cimport PPU

cdef class Memory:
    cdef PPU ppu
    cdef bytearray memory
    cdef bint mirrored

    cdef int read_byte(self, int address)
    cdef int read_word(self, int address)
    cdef write_byte(self, int address, int value)
    cdef int translate_address(self, int address)
    cdef int translate_cpu_address_to_rom(self, int address)