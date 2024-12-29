# cython: profile=True
# cython: linetrace=True

cdef class Registers:
    def __init__(self):
        self.A = 0
        self.X = 0
        self.Y = 0

        self.P = 0
        self.SP = 0
        self.PC = 0

    cdef inline bint is_p(self, int flag) noexcept nogil:
        return self.P & flag == flag

    cdef inline void set_p(self, int flag) noexcept nogil:
        self.P |= flag

    cdef inline void clear_p(self, int flag) noexcept nogil:
        self.P &= ~flag
