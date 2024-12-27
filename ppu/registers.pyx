from com.constants import PPU_REGISTER, PPUSTATUS_VBLANK, PPUCTRL, PATTERN_TABLE_OFFSET_0, PATTERN_TABLE_OFFSET_1, \
    NAME_TABLE_OFFSET
from ppu.memory import Memory


class Registers:
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

    def read_byte(self, address: int) -> int:
        if address == PPU_REGISTER.PPUCTRL: return self.PPUCTRL
        elif address == PPU_REGISTER.PPUMASK: return self.PPUMASK
        elif address == PPU_REGISTER.PPUSTATUS: return self.PPUSTATUS
        elif address == PPU_REGISTER.OAMADDR: return self.OAMADDR
        elif address == PPU_REGISTER.OAMDATA: return self.OAMDATA
        elif address == PPU_REGISTER.PPUSCROLL:
            value = self.PPUSCROLL[self.ppuscroll_write]
            self.ppuscroll_write ^= 1
            return value
        elif address == PPU_REGISTER.PPUADDR:
            value = self.PPUADDR[self.ppuaddr_write]
            self.ppuaddr_write ^= 1
            return value
        elif address == PPU_REGISTER.PPUDATA: return self.PPUDATA
        elif address == PPU_REGISTER.OAMDMA: return self.OAMDMA
        else:
            raise ValueError(f"unknown address ${address:x}")

    def write_byte(self, address: int, value: int):
        if address == PPU_REGISTER.PPUCTRL:
            self.PPUCTRL = value
            # name table
            name_table_index = self.PPUCTRL & 0b11
            self.name_table = NAME_TABLE_OFFSET[name_table_index]
            # sprite pattern table
            if self.is_ppuctrl(PPUCTRL.SPRITE_PATTERN_TABLE):
                self.sprite_pattern_table = PATTERN_TABLE_OFFSET_1
            else:
                self.sprite_pattern_table = PATTERN_TABLE_OFFSET_0
            # background pattern table
            if self.is_ppuctrl(PPUCTRL.BACKGROUND_PATTERN_TABLE):
                self.background_pattern_table = PATTERN_TABLE_OFFSET_1
            else:
                self.background_pattern_table = PATTERN_TABLE_OFFSET_0
        elif address == PPU_REGISTER.PPUMASK: self.PPUMASK = value
        elif address == PPU_REGISTER.PPUSTATUS: self.PPUSTATUS = value
        elif address == PPU_REGISTER.OAMADDR: self.OAMADDR = value
        elif address == PPU_REGISTER.OAMDATA: self.OAMDATA = value
        elif address == PPU_REGISTER.PPUSCROLL:
            self.PPUSCROLL[self.ppuscroll_write] = value
            self.ppuscroll_write ^= 1
        elif address == PPU_REGISTER.PPUADDR:
            self.PPUADDR[self.ppuaddr_write] = value
            self.ppuaddr_write ^= 1
        elif address == PPU_REGISTER.PPUDATA:
            self.PPUDATA = value
            ppuaddr = self.read_ppuaddr()
            self.memory.write_byte(ppuaddr, self.PPUDATA)
            increment = 32 if (self.PPUCTRL & 0b100) else 1
            self.write_ppuaddr((ppuaddr + increment) & 0x3FFF)
            # print(f"[@VRAM:${ppuaddr:x}] ${self.PPUDATA:x}")
        elif address == PPU_REGISTER.OAMDMA: self.OAMDMA = value
        else:
            raise ValueError(f"unknown address ${address:x}")

    def read_ppuaddr(self) -> int:
        return int.from_bytes(self.PPUADDR, byteorder="little")

    def write_ppuaddr(self, value: int):
        self.PPUADDR = bytearray(value.to_bytes(2, byteorder="little"))

    def is_ppuctrl(self, flag: int) -> bool:
        return self.PPUCTRL & flag == flag

    def set_ppuctrl(self):
        self.PPUSTATUS |= PPUSTATUS_VBLANK

    def clear_ppuctrl(self, flag: int):
        self.PPUCTRL &= ~flag

    def set_vblank(self):
        self.PPUSTATUS |= PPUSTATUS_VBLANK

    def clear_vblank(self):
        self.PPUSTATUS &= ~PPUSTATUS_VBLANK
