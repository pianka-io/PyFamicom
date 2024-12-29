# cython: profile=True
# cython: linetrace=True

cdef class Interrupt:
    def __init__(self):
        self.__triggered = False

    cdef inline void trigger(self) noexcept nogil:
        self.__triggered = True

    cdef inline bint active(self) noexcept nogil:
        return self.__triggered

    cdef inline void clear(self) noexcept nogil:
        self.__triggered = False
