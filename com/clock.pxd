cdef class Clock:
    cdef int cpu_cycles
    cdef int ppu_cycles
    cdef bint cpu_ready(self) nogil
    cdef bint ppu_ready(self) nogil