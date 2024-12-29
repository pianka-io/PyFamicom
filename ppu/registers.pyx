# cython: profile=True
# cython: linetrace=True

from com.constants cimport PPUSTATUS_VBLANK, PATTERN_TABLE_OFFSET_0, PATTERN_TABLE_OFFSET_1, \
    NAME_TABLE_OFFSET, PPU_REGISTER_PPUCTRL, PPU_REGISTER_PPUMASK, PPU_REGISTER_PPUSTATUS, PPU_REGISTER_OAMADDR, \
    PPU_REGISTER_OAMDATA, PPU_REGISTER_PPUSCROLL, PPU_REGISTER_PPUADDR, PPU_REGISTER_PPUDATA, PPU_REGISTER_OAMDMA, \
    PPUCTRL_BACKGROUND_PATTERN_TABLE, PPUCTRL_SPRITE_PATTERN_TABLE
from ppu.memory cimport Memory


cdef class Registers:
    def __init__(self, memory: Memory):
        self.memory = memory

        self.PPUCTRL = 0
        self.PPUMASK = 0
        self.PPUSTATUS = 0
        self.OAMADDR = 0
        self.OAMDATA = 0
        self.PPUSCROLL = bytearray(b'\0\0')
        self.PPUADDR = bytearray(b'\0\0')
        self.PPUDATA = 0
        self.OAMDMA = 0

        self.ppuscroll_read = 1
        self.ppuscroll_write = 1
        self.ppuaddr_read = 1
        self.ppuaddr_write = 1

        self.name_table = NAME_TABLE_OFFSET[0]
        self.sprite_pattern_table = PATTERN_TABLE_OFFSET_0
        self.background_pattern_table = PATTERN_TABLE_OFFSET_0

    cdef inline int read_byte(self, int address) noexcept nogil:
        if address == PPU_REGISTER_PPUCTRL: return self.PPUCTRL
        elif address == PPU_REGISTER_PPUMASK: return self.PPUMASK
        elif address == PPU_REGISTER_PPUSTATUS: return self.PPUSTATUS
        elif address == PPU_REGISTER_OAMADDR: return self.OAMADDR
        elif address == PPU_REGISTER_OAMDATA: return self.OAMDATA
        elif address == PPU_REGISTER_PPUSCROLL:
            value = self.PPUSCROLL[self.ppuscroll_write]
            self.ppuscroll_write ^= 1
            return value
        elif address == PPU_REGISTER_PPUADDR:
            value = self.PPUADDR[self.ppuaddr_write]
            self.ppuaddr_write ^= 1
            return value
        elif address == PPU_REGISTER_PPUDATA: return self.PPUDATA
        elif address == PPU_REGISTER_OAMDMA: return self.OAMDMA
        else:
            raise ValueError(f"unknown address ${address:x}")

    cdef inline void write_byte(self, int address, int value) noexcept nogil:
        cdef int ppuaddr
        cdef int increment
        cdef int result

        if address == PPU_REGISTER_PPUCTRL:
            self.PPUCTRL = value
            # name table
            name_table_index = self.PPUCTRL & 0b11
            self.name_table = NAME_TABLE_OFFSET[name_table_index]
            # sprite pattern table
            if self.is_ppuctrl(PPUCTRL_SPRITE_PATTERN_TABLE):
                self.sprite_pattern_table = PATTERN_TABLE_OFFSET_1
            else:
                self.sprite_pattern_table = PATTERN_TABLE_OFFSET_0
            # background pattern table
            if self.is_ppuctrl(PPUCTRL_BACKGROUND_PATTERN_TABLE):
                self.background_pattern_table = PATTERN_TABLE_OFFSET_1
            else:
                self.background_pattern_table = PATTERN_TABLE_OFFSET_0
        elif address == PPU_REGISTER_PPUMASK: self.PPUMASK = value
        elif address == PPU_REGISTER_PPUSTATUS: self.PPUSTATUS = value
        elif address == PPU_REGISTER_OAMADDR: self.OAMADDR = value
        elif address == PPU_REGISTER_OAMDATA: self.OAMDATA = value
        elif address == PPU_REGISTER_PPUSCROLL:
            self.PPUSCROLL[self.ppuscroll_write] = value
            self.ppuscroll_write ^= 1
        elif address == PPU_REGISTER_PPUADDR:
            self.PPUADDR[self.ppuaddr_write] = value
            self.ppuaddr_write ^= 1
        elif address == PPU_REGISTER_PPUDATA:
            self.PPUDATA = value
            ppuaddr = self.read_ppuaddr()
            self.memory.write_byte(ppuaddr, self.PPUDATA)
            increment = 32 if (self.PPUCTRL & 0b100) else 1
            result = (ppuaddr + increment) & 0x3FFF
            with gil:
                self.write_ppuaddr(result)
            # print(f"[@VRAM:${ppuaddr:x}] ${self.PPUDATA:x}")
        elif address == PPU_REGISTER_OAMDMA: self.OAMDMA = value
        else:
            raise ValueError(f"unknown address ${address:x}")

    cdef inline int read_ppuaddr(self) noexcept nogil:
        return (<int> (self.PPUADDR[1]) << 8) | <int> (self.PPUADDR[0])

    cdef inline void write_ppuaddr(self, int value) noexcept nogil:
        cdef char[2] ppuaddr_bytes
        ppuaddr_bytes[0] = <char> (value & 0xFF)
        ppuaddr_bytes[1] = <char> ((value >> 8) & 0xFF)

        self.PPUADDR[0] = ppuaddr_bytes[0]
        self.PPUADDR[1] = ppuaddr_bytes[1]

    cdef inline bint is_ppuctrl(self, int flag) noexcept nogil:
        return self.PPUCTRL & flag == flag

    cdef inline void set_ppuctrl(self) noexcept nogil:
        self.PPUSTATUS |= PPUSTATUS_VBLANK

    cdef inline void clear_ppuctrl(self, int flag) noexcept nogil:
        self.PPUCTRL &= ~flag

    cdef inline void set_vblank(self) noexcept nogil:
        self.PPUSTATUS |= PPUSTATUS_VBLANK

    cdef inline void clear_vblank(self) noexcept nogil:
        self.PPUSTATUS &= ~PPUSTATUS_VBLANK
