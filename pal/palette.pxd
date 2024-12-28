from com.pixel cimport Pixel


cdef class Palette:
    cdef char[1536] colors

    cdef Pixel color(self, int index) nogil
