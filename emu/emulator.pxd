from com.clock cimport Clock
from cpu.cpu cimport CPU
from com.interrupt cimport Interrupt
from ines.rom cimport ROM
from ppu.ppu cimport PPU
from tv.tv cimport TV


cdef class Emulator:
    cdef bint running
    cdef ROM rom
    cdef Clock clock
    cdef Interrupt nmi
    cdef TV tv
    cdef PPU ppu
    cdef CPU cpu

    cpdef start(self)
    cpdef stop(self)
