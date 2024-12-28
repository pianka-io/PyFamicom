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

    cdef void start(self) nogil
    cdef void stop(self) nogil
    cdef void spin(self, int cycles) nogil
    cdef void render(self) nogil
    cdef int pattern(self, int x, int y) nogil
    cdef void write_pixel(self, char[] frame, int x, int y, int r, int g, int b) nogil
    cdef double perf_counter(self) nogil
    cdef void pause(self, double seconds) nogil
