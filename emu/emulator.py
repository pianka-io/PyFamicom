from cpu.cpu import CPU
from ines.rom import ROM


class Emulator:
    def __init__(self, rom: ROM):
        self.rom = rom
        self.cpu = CPU(rom.prg_rom)

    def start(self):
        self.cpu.start()
