cdef class Interrupt:
    cdef bint __triggered

    cdef void trigger(self) nogil
    cdef bint active(self) nogil
    cdef void clear(self) nogil
