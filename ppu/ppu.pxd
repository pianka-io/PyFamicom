from com.clock cimport Clock
from com.interrupt cimport Interrupt
from pal.palette cimport Palette
from ppu.memory cimport Memory
from ppu.registers cimport Registers
from tv.tv cimport TV

cdef class PPU:
    cdef bint running
    cdef Clock clock
    cdef TV tv
    cdef Palette pal
    cdef Interrupt nmi
    cdef Memory memory
    cdef Registers registers
    cdef int dump

    cdef double timer
    cdef int frames

    cdef start(self)
    cdef stop(self)
    cdef spin(self, int cycles)
    cdef render(self)
    cdef int pattern(self, int x, int y)
