cdef class Registers:
    def __init__(self):
        self.A = 0
        self.X = 0
        self.Y = 0

        self.P = 0
        self.SP = 0
        self.PC = 0

    cdef bint is_p(self, int flag) nogil:
        return self.P & flag == flag

    cdef void set_p(self, int flag) nogil:
        self.P |= flag

    cdef void clear_p(self, int flag) nogil:
        self.P &= ~flag
