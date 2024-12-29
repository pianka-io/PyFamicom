from com.clock cimport Clock
from com.interrupt cimport Interrupt
from pal.palette cimport Palette
from ppu.memory cimport Memory
from ppu.registers cimport Registers
from tv.tv cimport TV

cdef class PPU:
    cdef Clock clock
    cdef TV tv
    cdef Palette pal
    cdef Interrupt nmi
    cdef Memory memory
    cdef Registers registers
    cdef bint vblank

    cdef double timer
    cdef int frames

    cdef void tick(self) noexcept nogil
    cdef inline void track_cycles(self, int cycles) noexcept nogil
    cdef inline void render(self) noexcept nogil
    cdef inline int pattern(self, int x, int y) noexcept nogil
    cdef inline void write_pixel(self, char[] frame, int x, int y, int r, int g, int b) noexcept nogil
    cdef inline double perf_counter(self) noexcept nogil
