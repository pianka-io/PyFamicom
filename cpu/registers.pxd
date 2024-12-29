cdef class Registers:
    cdef int A
    cdef int X
    cdef int Y
    cdef int P
    cdef int SP
    cdef int PC
    
    cdef inline bint is_p(self, int flag) noexcept nogil
    cdef inline void set_p(self, int flag) noexcept nogil
    cdef inline void clear_p(self, int flag) noexcept nogil
