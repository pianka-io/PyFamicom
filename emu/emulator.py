from threading import Thread
from time import sleep

from cpu.cpu import CPU
from common.interrupt import Interrupt
from ines.rom import ROM
from ppu.ppu import PPU


class Emulator:
    def __init__(self, rom: ROM):
        self.running = False
        self.rom = rom
        self.nmi = Interrupt()
        self.ppu = PPU(self.nmi)
        self.cpu = CPU(self.ppu, self.nmi, rom.prg_rom)

    def start(self):
        self.running = True
        cpu_thread = Thread(target=self.cpu.start)
        ppu_thread = Thread(target=self.ppu.start)

        ppu_thread.start()
        cpu_thread.start()

        try:
            while self.running:
                sleep(100)
        finally:
            self.cpu.stop()
            self.ppu.stop()

    def stop(self):
        self.running = False
