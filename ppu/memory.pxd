cdef class Memory:
    cdef bytearray memory

    cdef int read_byte(self, int address) nogil
    cdef void write_byte(self, int address, int value) nogil
    cdef int translate_address(self, int address) nogil
