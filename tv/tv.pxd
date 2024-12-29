from com.pixel cimport Pixel

from com.interrupt cimport Interrupt

cdef class TV:
    cdef char[256*240*3] frame
    cdef Interrupt quit
    cdef object screen
    cdef object pixel_surface

    cdef void tick(self)
    cdef inline Pixel read_pixel(self, int x, int y) noexcept nogil