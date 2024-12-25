class Header:
    def __init__(self, nes: str, prg_rom: int, chr_rom: int, flags: int):
        self.nes = nes
        self.prg_rom = prg_rom
        self.chr_rom = chr_rom
        self.flags = flags


class ROM:
    def __init__(self, header: Header, prg_rom: bytes):
        self.header = header
        self.prg_rom = prg_rom
