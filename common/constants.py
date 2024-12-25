HEADER_SIZE = 0x10
CPU_MEMORY_SIZE = 0x10000

PRG_OFFSET = 0x8000
PRG_BANK_SIZE = 0x4000

RESET_VECTOR = 0xFFFC

CPU_STATUS_CARRY = 0b00000001
CPU_STATUS_ZERO = 0b00000010
CPU_STATUS_INTERRUPT = 0b00000100
CPU_STATUS_BCD = 0b00001000
CPU_STATUS_BREAK = 0b00010000
CPU_STATUS_UNUSED = 0b00100000
CPU_STATUS_OVERFLOW = 0b01000000
CPU_STATUS_NEGATIVE = 0b10000000


class PPU_REGISTER:
    PPUCTRL = 0x2000
    PPUMASK = 0x2001
    PPUSTATUS = 0x2002
    OAMADDR = 0x2003
    OAMDATA = 0x2004
    PPUSCROLL = 0x2005
    PPUADDR = 0x2006
    PPUDATA = 0x2007
    OAMDMA = 0x2008


PPUSTATUS_VBLANK = 0b10000000
