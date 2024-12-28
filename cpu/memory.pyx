from com.constants cimport PRG_OFFSET, PRG_BANK_SIZE, HEADER_SIZE, CPU_MEMORY_SIZE, PPU_REGISTER_OAMDMA, \
    PPU_REGISTER_PPUCTRL
from ppu.ppu cimport PPU


cdef class Memory:
    def __init__(self, ppu: PPU, prg_rom: bytes):
        self.ppu = ppu
        self.memory = bytearray(CPU_MEMORY_SIZE)
        self.memory[PRG_OFFSET:CPU_MEMORY_SIZE] = prg_rom
        self.mirrored = len(prg_rom) <= PRG_BANK_SIZE

    cdef int read_byte(self, int address):
        if PPU_REGISTER_PPUCTRL <= address <= PPU_REGISTER_OAMDMA:
            return self.ppu.registers.read_byte(address)
        translated = self.translate_address(address)
        return self.memory[translated]

    cdef int read_word(self, int address):
        translated = self.translate_address(address)
        value = self.memory[translated:translated + 2]
        return int.from_bytes(value, byteorder='little')

    cdef void write_byte(self, int address, int value):
        if PPU_REGISTER_PPUCTRL <= address <= PPU_REGISTER_OAMDMA:
            self.ppu.registers.write_byte(address, value)
            return
        translated = self.translate_address(address)
        self.memory[translated] = value & 0xFF

    cdef int translate_address(self, int address) nogil:
        if self.mirrored and address > PRG_OFFSET + PRG_BANK_SIZE:
            return address - PRG_BANK_SIZE
        else:
            return address

    cdef int translate_cpu_address_to_rom(self, int address) nogil:
        cdef int onset = address - PRG_OFFSET
        if self.mirrored and onset > PRG_BANK_SIZE:
            onset -= PRG_BANK_SIZE
        return onset + HEADER_SIZE
