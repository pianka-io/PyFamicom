cdef class Clock:
    def __init__(self):
        self.cpu_cycles = 0
        self.ppu_cycles = 0

    cdef bint cpu_ready(self) nogil:
        return True

    cdef bint ppu_ready(self) nogil:
        return self.ppu_cycles >= self.cpu_cycles * 3
