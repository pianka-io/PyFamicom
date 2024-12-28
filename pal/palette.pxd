cdef class Palette:
    cdef bytes colors

    cdef (int, int, int) color(self, int index)
