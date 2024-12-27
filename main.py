from emu.emulator import Emulator
from ines.rom import ROM


def main():
    rom = ROM.load("roms/tests/1.Branch_Basics.nes")
    emu = Emulator(rom)
    emu.start()


if __name__ == '__main__':
    main()

