from ines.rom import Header, ROM


def load_rom(filename: str):
    with open(filename, "rb") as file:
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