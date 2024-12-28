from ppu.ppu cimport PPU

cdef class Memory:
    cdef PPU ppu
    cdef bytearray memory
    cdef bint mirrored

    cdef int read_byte(self, int address) nogil
    cdef int read_word(self, int address) nogil
    cdef void write_byte(self, int address, int value) nogil
    cdef int translate_address(self, int address) nogil
    cdef int translate_cpu_address_to_rom(self, int address) nogil
