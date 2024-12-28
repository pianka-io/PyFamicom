cdef class Registers:
    cdef int A
    cdef int X
    cdef int Y
    cdef int P
    cdef int SP
    cdef int PC
    
    cdef bint is_p(self, int flag)
    cdef set_p(self, int flag)
    cdef clear_p(self, int flag)
