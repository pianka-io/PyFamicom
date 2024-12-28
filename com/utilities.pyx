cdef int signed_byte(int value):
    if value > 127:
        return value - 256
    else:
        return value
