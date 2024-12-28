from ppu.memory cimport Memory


cdef class Registers:
    cdef Memory memory

    cdef int PPUCTRL
    cdef int PPUMASK
    cdef int PPUSTATUS
    cdef int OAMADDR
    cdef int OAMDATA
    cdef bytearray PPUSCROLL
    cdef bytearray PPUADDR
    cdef int PPUDATA
    cdef int OAMDMA

    cdef int ppuscroll_read
    cdef int ppuscroll_write
    cdef int ppuaddr_read
    cdef int ppuaddr_write

    cdef int name_table
    cdef int sprite_pattern_table
    cdef int background_pattern_table

    cdef int read_byte(self, int address) nogil
    cdef void write_byte(self, int address, int value) nogil
    cdef int read_ppuaddr(self) nogil
    cdef void write_ppuaddr(self, int value) nogil
    cdef bint is_ppuctrl(self, int flag) nogil
    cdef void set_ppuctrl(self) nogil
    cdef void clear_ppuctrl(self, int flag) nogil
    cdef void set_vblank(self) nogil
    cdef void clear_vblank(self) nogil
    