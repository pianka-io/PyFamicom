cdef struct Pixel:
    unsigned char r
    unsigned char g
    unsigned char b

cdef class Frame:
    cdef char[256 * 240 * 3] pixels

    cdef write_pixel(self, int x, int y, int r, int g, int b)
    cdef Pixel read_pixel(self, int x, int y)
