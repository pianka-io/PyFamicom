cdef class Interrupt:
    def __init__(self):
        self.__triggered = False

    cdef void trigger(self) nogil:
        self.__triggered = True

    cdef bint active(self) nogil:
        return self.__triggered

    cdef void clear(self) nogil:
        self.__triggered = False
