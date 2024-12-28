cdef class Memory:
    cdef bytearray memory

    cdef int read_byte(self, int address)
    cdef write_byte(self, int address, int value)
    cdef int translate_address(self, int address)
