cdef class Registers:
    def __init__(self):
        self.A = 0
        self.X = 0
        self.Y = 0

        self.P = 0
        self.SP = 0
        self.PC = 0

    cdef bint is_p(self, int flag):
        return self.P & flag == flag

    cdef set_p(self, int flag):
        self.P |= flag

    cdef clear_p(self, int flag):
        self.P &= ~flag
