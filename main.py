# import yappi
import pstats

from emu.emulator import Emulator
from ines.rom import ROM
from pal.palette import Palette
import cProfile


def main():
    rom = ROM.load("bin/tests/1.Branch_Basics.nes")
    pal = Palette.load("bin/pals/Composite.pal")
    emu = Emulator(rom, pal)

    # yappi.set_clock_type("wall")
    # yappi.start(builtins=True)

    emu.start()
    # p.sort_stats('cumulative').print_stats(10)
    # yappi.stop()

    # yappi.get_thread_stats().print_all()
    # yappi.get_func_stats().save("function_stats.pstat", type="pstat")
    # yappi.get_func_stats().print_all()


if __name__ == '__main__':
    cProfile.run('main()')
    # p = pstats.Stats('profile_output.prof')
    # main()

