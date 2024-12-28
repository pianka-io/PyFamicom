cdef int ADDR_IMPLICIT
cdef int ADDR_ACCUMULATOR
cdef int ADDR_IMMEDIATE
cdef int ADDR_ZERO
cdef int ADDR_ZERO_X
cdef int ADDR_ZERO_Y
cdef int ADDR_RELATIVE
cdef int ADDR_ABSOLUTE
cdef int ADDR_ABSOLUTE_X
cdef int ADDR_ABSOLUTE_Y
cdef int ADDR_INDIRECT
cdef int ADDR_INDEXED_INDIRECT
cdef int ADDR_INDIRECT_INDEXED


cdef int argument_size(int addressing) nogil