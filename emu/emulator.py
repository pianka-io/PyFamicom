from threading import Thread
from time import sleep

from cpu.cpu import CPU
from ines.rom import ROM
from ppu.ppu import PPU


class Emulator:
    def __init__(self, rom: ROM):
        self.running = False
        self.rom = rom
        self.ppu = PPU()
        self.cpu = CPU(self.ppu.registers, rom.prg_rom)

    def start(self):
        self.running = True
        cpu_thread = Thread(target=self.cpu.start)
        ppu_thread = Thread(target=self.ppu.start)

        cpu_thread.start()
        ppu_thread.start()

        try:
            while self.running:
                sleep(100)
        finally:
            self.cpu.stop()
            self.ppu.stop()

    def stop(self):
        self.running = False
