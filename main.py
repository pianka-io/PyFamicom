import cProfile
import pstats

from emu.emulator import Emulator
from ines.rom import ROM
from pal.palette import Palette


def main():
    rom = ROM.load("bin/tests/1.Branch_Basics.nes")
    pal = Palette.load("bin/pals/Composite.pal")
    emu = Emulator(rom, pal)

    profiler = cProfile.Profile()
    profiler.enable()
    emu.start()
    profiler.disable()

    stats = pstats.Stats(profiler)
    stats.sort_stats("cumulative").print_stats(50)


if __name__ == '__main__':
    main()

