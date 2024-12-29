cdef class Memory:
    cdef unsigned char[0x4000] memory

    cdef int read_byte(self, int address) noexcept nogil
    cdef void write_byte(self, int address, int value) noexcept nogil
    cdef int translate_address(self, int address) noexcept nogil
