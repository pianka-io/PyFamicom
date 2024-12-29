# cython: profile=True
# cython: linetrace=True

cdef class Clock:
    def __init__(self):
        self.cpu_cycles = 0
        self.ppu_cycles = 0

    cdef inline bint cpu_ready(self) noexcept nogil:
        return True

    cdef inline bint ppu_ready(self) noexcept nogil:
        return self.cpu_cycles >= self.ppu_cycles * 3
