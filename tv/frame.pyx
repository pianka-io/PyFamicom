from com.constants cimport TV_WIDTH, TV_HEIGHT


cdef class Frame:
    def __init__(self):
        # self.pixels = char[TV_WIDTH * TV_HEIGHT * 3]
        ...

    cdef write_pixel(self, int x, int y, int r, int g, int b):
        index = (y * TV_WIDTH + x) * 3
        self.pixels[index] = r
        self.pixels[index + 1] = g
        self.pixels[index + 2] = b

    cdef Pixel read_pixel(self, int x, int y):
        cdef int index = (y * TV_WIDTH + x) * 3
        cdef Pixel pixel
        pixel.r = self.pixels[index]
        pixel.g = self.pixels[index + 1]
        pixel.b = self.pixels[index + 2]
        return pixel
