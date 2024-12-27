from emu.emulator import Emulator
from ines.rom import ROM
from pal.palette import Palette


def main():
    rom = ROM.load("bin/tests/1.Branch_Basics.nes")
    pal = Palette.load("bin/pals/2C02G.pal")
    emu = Emulator(rom, pal)
    emu.start()


if __name__ == '__main__':
    main()

