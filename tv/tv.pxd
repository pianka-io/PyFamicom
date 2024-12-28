from com.pixel cimport Pixel


cdef class TV:
    cdef bint running
    cdef char[256*240*3] frame
    cdef object screen
    cdef object pixel_surface

    cdef void tick(self)
    cdef void stop(self) nogil
    cdef Pixel read_pixel(self, int x, int y) noexcept nogil