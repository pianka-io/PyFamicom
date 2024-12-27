from common.constants import PPU_MEMORY_SIZE, NAME_TABLE_MIRROR_OFFSET_0, NAME_TABLE_MIRROR_OFFSET_1


class Memory:
    def __init__(self):
        self.memory = bytearray(PPU_MEMORY_SIZE)

    def read_byte(self, address: int) -> int:
        translated = self.translate_address(address)
        return self.memory[translated]

    def write_byte(self, address: int, value: int):
        translated = self.translate_address(address)
        self.memory[translated] = value & 0xFF

    def translate_address(self, address: int) -> int:
        if NAME_TABLE_MIRROR_OFFSET_0 <= address <= NAME_TABLE_MIRROR_OFFSET_1:
            return address - 0x1000
        return address
