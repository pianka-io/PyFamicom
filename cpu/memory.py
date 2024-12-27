from common.constants import PRG_OFFSET, PRG_BANK_SIZE, HEADER_SIZE, CPU_MEMORY_SIZE, PPU_REGISTER
from ppu.ppu import PPU


class Memory:
    def __init__(self, ppu: PPU, prg_rom: bytes):
        self.ppu = ppu
        self.memory = bytearray(CPU_MEMORY_SIZE)
        self.memory[PRG_OFFSET:CPU_MEMORY_SIZE] = prg_rom
        self.mirrored = len(prg_rom) <= PRG_BANK_SIZE

    def read_byte(self, address: int) -> int:
        if PPU_REGISTER.PPUCTRL <= address <= PPU_REGISTER.OAMDMA:
            return self.ppu.registers.read_byte(address)
        translated = self.translate_address(address)
        return self.memory[translated]

    def read_word(self, address: int) -> int:
        translated = self.translate_address(address)
        value = self.memory[translated:translated + 2]
        return int.from_bytes(value, byteorder='little')

    def write_byte(self, address: int, value: int):
        if PPU_REGISTER.PPUCTRL <= address <= PPU_REGISTER.OAMDMA:
            self.ppu.registers.write_byte(address, value)
            return
        translated = self.translate_address(address)
        self.memory[translated] = value & 0xFF

    def translate_address(self, address: int) -> int:
        if self.mirrored and address > PRG_OFFSET + PRG_BANK_SIZE:
            return address - PRG_BANK_SIZE
        else:
            return address

    def translate_cpu_address_to_rom(self, address: int) -> int:
        onset = address - PRG_OFFSET
        if self.mirrored and onset > PRG_BANK_SIZE:
            onset -= PRG_BANK_SIZE
        return onset + HEADER_SIZE
