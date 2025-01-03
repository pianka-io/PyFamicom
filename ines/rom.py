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

    @staticmethod
    def load(path: str):
        with open(path, "rb") as file:
            ines = file.read()

        # header
        nes = ines[0:3]
        prg_rom = ines[4]
        chr_rom = ines[5]
        flags = ines[6]
        header = Header(nes.decode("utf-8"), prg_rom, chr_rom, flags)

        # prg rom
        prg_rom_size = prg_rom * 0x4000  # KiB
        prg_rom_bytes = ines[0x10:0x10 + prg_rom_size]

        return ROM(header, prg_rom_bytes)
