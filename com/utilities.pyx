cdef int signed_byte(int value) noexcept nogil:
    if value > 127:
        return value - 256
    else:
        return value
