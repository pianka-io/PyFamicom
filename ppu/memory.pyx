from com.constants cimport PPU_MEMORY_SIZE, NAME_TABLE_MIRROR_OFFSET_0, NAME_TABLE_MIRROR_OFFSET_1


cdef class Memory:
    def __init__(self):
        self.memory = bytearray(PPU_MEMORY_SIZE)

    cdef int read_byte(self, int address):
        translated = self.translate_address(address)
        return self.memory[translated]

    cdef write_byte(self, int address, int value):
        translated = self.translate_address(address)
        self.memory[translated] = value & 0xFF

    cdef int translate_address(self, int address):
        if NAME_TABLE_MIRROR_OFFSET_0 <= address <= NAME_TABLE_MIRROR_OFFSET_1:
            return address - 0x1000
        return address
