cdef class Interrupt:
    cdef bint __triggered

    cdef trigger(self)
    cdef active(self)
    cdef clear(self)
