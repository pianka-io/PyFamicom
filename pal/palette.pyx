# cython: profile=True
# cython: linetrace=True

from com.pixel cimport Pixel


cdef class Palette:
    def __init__(self, colors: bytes):
        for i in range(len(colors)):
            self.colors[i] = colors[i]

    @staticmethod
    def load(path: str):
        cdef bytes contents
        with open(path, 'rb') as file:
            contents = file.read()

        return Palette(contents)

    cdef Pixel color(self, int index) noexcept nogil:
        cdef int offset = index * 3
        cdef Pixel result
        cdef const char * raw_colors = <const char *> self.colors
        result.r = raw_colors[offset]
        result.g = raw_colors[offset+1]
        result.b = raw_colors[offset+2]
        return result
