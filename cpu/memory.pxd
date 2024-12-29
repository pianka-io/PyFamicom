from ppu.ppu cimport PPU

cdef class Memory:
    cdef PPU ppu
    cdef unsigned char[0x10000] memory
    cdef bint mirrored

    cdef int read_byte(self, int address) noexcept nogil
    cdef int read_word(self, int address) noexcept nogil
    cdef void write_byte(self, int address, int value) noexcept nogil
    cdef inline int translate_address(self, int address) noexcept nogil
    cdef inline int translate_cpu_address_to_rom(self, int address) noexcept nogil
