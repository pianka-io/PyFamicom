from common.constants import PRG_OFFSET, PRG_BANK_SIZE, HEADER_SIZE


class Memory:
    def __init__(self, prg_rom: bytes):
        self.memory = bytearray(0x10000)
        self.memory[0x8000:0x10000] = prg_rom
        self.mirrored = len(prg_rom) <= PRG_BANK_SIZE

    def read_byte(self, address: int) -> int:
        translated = self.translate_address(address)
        return self.memory[translated]

    def read_word(self, address: int) -> int:
        translated = self.translate_address(address)
        value = self.memory[translated:translated + 2]
        return int.from_bytes(value, byteorder='little')

    def write_byte(self, address: int, value: int):
        translated = self.translate_address(address)
        self.memory[translated] = value

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
