cdef class Clock:
    cdef int cpu_cycles
    cdef int ppu_cycles
    cdef inline bint cpu_ready(self) noexcept nogil
    cdef inline bint ppu_ready(self) noexcept nogil