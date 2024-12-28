cdef class Clock:
    def __init__(self):
        self.cpu_cycles = 0
        self.ppu_cycles = 0

    cdef cpu_ready(self):
        return True

    cdef ppu_ready(self):
        return self.ppu_cycles >= self.cpu_cycles * 3
