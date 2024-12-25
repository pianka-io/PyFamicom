from cpu.cpu import CPU
from ines.rom import ROM
from ppu.ppu import PPU


class Emulator:
    def __init__(self, rom: ROM):
        self.rom = rom
        self.ppu = PPU()
        self.cpu = CPU(self.ppu.registers, rom.prg_rom)

    def start(self):
        self.cpu.start()
