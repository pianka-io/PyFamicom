from com.pixel cimport Pixel


cdef class TV:
    cdef bint running
    cdef char[256*240*3] frame

    cdef start(self)
    cdef Pixel read_pixel(self, int x, int y) noexcept nogil