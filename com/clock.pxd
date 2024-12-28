cdef class Clock:
    cdef int cpu_cycles
    cdef int ppu_cycles
    cdef cpu_ready(self)
    cdef ppu_ready(self)