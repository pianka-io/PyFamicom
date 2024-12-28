cdef class Interrupt:
    def __init__(self):
        self.__triggered = False

    cdef trigger(self):
        self.__triggered = True

    cdef active(self):
        return self.__triggered

    cdef clear(self):
        self.__triggered = False
