import yappi

from emu.emulator import Emulator
from ines.rom import ROM
from pal.palette import Palette


def main():
    rom = ROM.load("bin/tests/1.Branch_Basics.nes")
    pal = Palette.load("bin/pals/Composite.pal")
    emu = Emulator(rom, pal)

    yappi.start()
    emu.start()
    yappi.stop()

    yappi.get_thread_stats().print_all()
    # yappi.get_func_stats().print_all()


if __name__ == '__main__':
    main()

