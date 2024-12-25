from emu.emulator import Emulator
from ines.loader import load_rom


def main():
    rom = load_rom("roms/tests/1.Branch_Basics.nes")
    emu = Emulator(rom)
    emu.start()


if __name__ == '__main__':
    main()
