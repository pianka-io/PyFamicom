import time
from time import sleep

from com.clock import Clock
from com.interrupt import Interrupt
from pal.palette import Palette
from ppu.memory import Memory
from ppu.registers import Registers
from tv.frame import Frame
from tv.tv import TV


class PPU:
    def __init__(self, clock: Clock, tv: TV, pal: Palette, nmi: Interrupt):
        self.running = False
        self.clock = clock
        self.tv = tv
        self.pal = pal
        self.nmi = nmi
        self.memory = Memory()
        self.registers = Registers(self.memory)
        self.dump = 0

        self.timer = time.perf_counter()
        self.frames = 0

    def start(self):
        self.running = True
        while self.running:
            sleep(0)
            self.spin(2273)  # 20 * 341
            self.registers.set_vblank()
            self.nmi.trigger()
            time.sleep(0.000423)  # 2273 PPU cycles, and the PPU runs at 5.369318 MHz
            self.registers.clear_vblank()
            self.spin(84514)  # (240+1)×341
            self.render()

    def stop(self):
        self.running = False

    def spin(self, cycles: int):
        self.clock.ppu_cycles += cycles
        if not self.clock.cpu_ready():
            sleep(0)

    def render(self):
        delta = time.perf_counter() - self.timer
        if delta > 1.0:
            print(f"Frame Rate: {self.frames}/s {self.clock.cpu_cycles}")
            self.timer = time.perf_counter()
            self.frames = 0
        self.frames += 1

        frame = Frame()
        self.dump += 1
        for tile_y in range(30):
            for tile_x in range(32):
                attribute_table_address = self.registers.name_table + 0x03C0
                attribute_address = attribute_table_address + ((tile_y // 4) * 8) + (tile_x // 4)
                attribute_byte = self.memory.read_byte(attribute_address)
                shift = ((tile_y % 4) // 2) * 4 + ((tile_x % 4) // 2) * 2
                palette_index = (attribute_byte >> shift) & 0b11

                pattern_index = self.pattern(tile_x, tile_y)
                tile_address = self.registers.background_pattern_table + (pattern_index * 16)

                for row in range(8):
                    low_byte = self.memory.read_byte(tile_address + row)
                    high_byte = self.memory.read_byte(tile_address + row + 8)
                    for bit in range(8):
                        pixel_value = (((high_byte >> (7 - bit)) & 1) << 1) | ((low_byte >> (7 - bit)) & 1)
                        palette_address = 0x3F00 + (palette_index * 4) + pixel_value
                        color_index = self.memory.read_byte(palette_address)
                        r, g, b = self.pal.color(color_index)
                        pixel_x = tile_x * 8 + bit
                        pixel_y = tile_y * 8 + row
                        frame.write_pixel(pixel_x, pixel_y, r, g, b)

        self.tv.frame = frame

    def pattern(self, x: int, y: int) -> int:
        base = self.registers.name_table
        offset = y * 32 + x
        address = base + offset
        return self.memory.read_byte(address)
