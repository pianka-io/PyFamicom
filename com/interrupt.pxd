cdef class Interrupt:
    cdef bint __triggered

    cdef inline void trigger(self) noexcept nogil
    cdef inline bint active(self) noexcept nogil
    cdef inline void clear(self) noexcept nogil
