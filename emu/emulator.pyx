from threading import Thread

from com.clock import Clock
from cpu.cpu import CPU
from com.interrupt import Interrupt
from ines.rom import ROM
from pal.palette import Palette
from ppu.ppu import PPU
from tv.tv import TV


cdef class Emulator:
    def __init__(self, rom: ROM, pal: Palette):
        self.running = False
        self.rom = rom
        self.clock = Clock()
        self.nmi = Interrupt()
        self.tv = TV()
        self.ppu = PPU(self.clock, self.tv, pal, self.nmi)
        self.cpu = CPU(self.clock, self.ppu, self.nmi, rom.prg_rom)

    cpdef start(self):
        self.running = True
        cpu_thread = Thread(target=self.cpu.start)
        ppu_thread = Thread(target=self.ppu.start)

        ppu_thread.start()
        cpu_thread.start()

        self.tv.start()

        self.cpu.stop()
        self.ppu.stop()

    cpdef stop(self):
        self.running = False
