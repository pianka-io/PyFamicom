from common.constants import PPU_REGISTER


class Registers:
    def __init__(self):
        self.PPUCTRL = 0
        self.PPUMASK = 0
        self.PPUSTATUS = 0
        self.OAMADDR = 0
        self.OAMDATA = 0
        self.PPUSCROLL = bytearray(b'\0\0')
        self.PPUADDR = bytearray(b'\0\0')
        self.PPUDATA = 0
        self.OAMDMA = 0

        self.ppuscroll_read = 0
        self.ppuscroll_write = 0
        self.ppuaddr_read = 0
        self.ppuaddr_write = 0

    def read_byte(self, address: int) -> int:
        match address:
            case PPU_REGISTER.PPUCTRL: return self.PPUCTRL
            case PPU_REGISTER.PPUMASK: return self.PPUMASK
            case PPU_REGISTER.PPUSTATUS: return self.PPUSTATUS
            case PPU_REGISTER.OAMADDR: return self.OAMADDR
            case PPU_REGISTER.OAMDATA: return self.OAMDATA
            case PPU_REGISTER.PPUSCROLL:
                value = self.PPUSCROLL[self.ppuscroll_write]
                self.ppuscroll_write ^= 1
                return value
            case PPU_REGISTER.PPUADDR:
                value = self.PPUADDR[self.ppuaddr_write]
                self.ppuaddr_write ^= 1
                return value
            case PPU_REGISTER.PPUDATA: return self.PPUDATA
            case PPU_REGISTER.OAMDMA: return self.OAMDMA
            case _:
                raise ValueError(f"unknown address ${address:x}")

    def write_byte(self, address: int, value: int):
        match address:
            case PPU_REGISTER.PPUCTRL: self.PPUCTRL = value
            case PPU_REGISTER.PPUMASK: self.PPUMASK = value
            case PPU_REGISTER.PPUSTATUS: self.PPUSTATUS = value
            case PPU_REGISTER.OAMADDR: self.OAMADDR = value
            case PPU_REGISTER.OAMDATA: self.OAMDATA = value
            case PPU_REGISTER.PPUSCROLL:
                self.PPUSCROLL[self.ppuscroll_write] = value
                self.ppuscroll_write ^= 1
            case PPU_REGISTER.PPUADDR:
                self.PPUADDR[self.ppuaddr_write] = value
                self.ppuaddr_write ^= 1
            case PPU_REGISTER.PPUDATA: self.PPUDATA = value
            case PPU_REGISTER.OAMDMA: self.OAMDMA = value
            case _:
                raise ValueError(f"unknown address ${address:x}")
