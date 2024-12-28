cdef int ADDR_IMPLICIT = 1
cdef int ADDR_ACCUMULATOR = 2
cdef int ADDR_IMMEDIATE = 3
cdef int ADDR_ZERO = 4
cdef int ADDR_ZERO_X = 5
cdef int ADDR_ZERO_Y = 6
cdef int ADDR_RELATIVE = 7
cdef int ADDR_ABSOLUTE = 8
cdef int ADDR_ABSOLUTE_X = 9
cdef int ADDR_ABSOLUTE_Y = 10
cdef int ADDR_INDIRECT = 11
cdef int ADDR_INDEXED_INDIRECT = 12
cdef int ADDR_INDIRECT_INDEXED = 13


cdef int argument_size(int addressing) nogil:
    if addressing == ADDR_IMPLICIT:
        return 0
    if addressing in [ADDR_IMMEDIATE, ADDR_RELATIVE, ADDR_ZERO, ADDR_INDIRECT_INDEXED]:
        return 1
    if addressing in [ADDR_ABSOLUTE, ADDR_ABSOLUTE_X]:
        return 2
    raise ValueError(f"unsupported addressing mode: {addressing.name}")
