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

    cdef inline int read_byte(self, int address) noexcept nogil
    cdef inline void write_byte(self, int address, int value) noexcept nogil
    cdef inline int read_ppuaddr(self) noexcept nogil
    cdef inline void write_ppuaddr(self, int value) noexcept nogil
    cdef inline bint is_ppuctrl(self, int flag) noexcept nogil
    cdef inline void set_ppuctrl(self) noexcept nogil
    cdef inline void clear_ppuctrl(self, int flag) noexcept nogil
    cdef inline void set_vblank(self) noexcept nogil
    cdef inline void clear_vblank(self) noexcept nogil
    