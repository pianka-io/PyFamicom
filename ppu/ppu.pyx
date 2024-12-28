import time

from com.clock cimport Clock
from com.constants cimport TV_WIDTH
from com.interrupt cimport Interrupt
from com.pixel cimport Pixel
from pal.palette cimport Palette
from ppu.memory cimport Memory
from ppu.registers cimport Registers
from tv.tv cimport TV



cdef class PPU:
    def __init__(self, clock: Clock, tv: TV, pal: Palette, nmi: Interrupt):
        self.running = False
        self.clock = clock
        self.tv = tv
        self.pal = pal
        self.nmi = nmi
        self.memory = Memory()
        self.registers = Registers(self.memory)

        self.timer = self.perf_counter()
        self.frames = 0
        self.vblank = True

    cdef void tick(self) nogil:
        if self.vblank:
            self.registers.set_vblank()
            self.nmi.trigger()
            self.track_cycles(2273)
        else:
            self.registers.clear_vblank()
            self.render()
            self.track_cycles(84514)
        self.vblank = not self.vblank

    cdef void track_cycles(self, int cycles) nogil:
        cdef int result = self.clock.ppu_cycles + cycles
        self.clock.ppu_cycles = result

    cdef void render(self) nogil:
        cdef double delta
        with gil:
            delta = self.perf_counter() - self.timer
        if delta > 1.0:
            with gil:
                print(f"Frame Rate: {self.frames}/s {self.clock.cpu_cycles}")
                self.timer = self.perf_counter()
            self.frames = 0
        self.frames += 1

        cdef int attribute_table_address
        cdef int attribute_address
        cdef int attribute_byte
        cdef int shift
        cdef int palette_index
        cdef int pattern_index
        cdef int tile_address
        cdef int low_byte
        cdef int high_byte
        cdef int pixel_value
        cdef int palette_address
        cdef int color_index
        cdef Pixel pixel
        cdef int pixel_x
        cdef int pixel_y
        cdef int tile_x
        cdef int tile_y
        cdef int row
        cdef int col

        cdef char[256*240*3] frame
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
                    for col in range(8):
                        pixel_value = (((high_byte >> (7 - col)) & 1) << 1) | ((low_byte >> (7 - col)) & 1)
                        palette_address = 0x3F00 + (palette_index * 4) + pixel_value
                        color_index = self.memory.read_byte(palette_address)
                        pixel = self.pal.color(color_index)
                        pixel_x = tile_x * 8 + col
                        pixel_y = tile_y * 8 + row
                        self.write_pixel(frame, pixel_x, pixel_y, pixel.r, pixel.g, pixel.b)

        self.tv.frame = frame

    cdef int pattern(self, int x, int y) nogil:
        cdef int base = self.registers.name_table
        cdef int offset = y * 32 + x
        cdef int address = base + offset
        return self.memory.read_byte(address)

    cdef void write_pixel(self, char[] frame, int x, int y, int r, int g, int b) nogil:
        cdef int index = (y * TV_WIDTH + x) * 3
        frame[index] = r
        frame[index + 1] = g
        frame[index + 2] = b

    cdef double perf_counter(self) nogil:
        cdef double now
        with gil:
            now = time.perf_counter()
        return now

    cdef void pause(self, double seconds) nogil:
        with gil:
            time.sleep(seconds)
