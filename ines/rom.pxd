cdef class Header:
    cdef str nes
    cdef int prg_rom
    cdef int chr_rom
    cdef int flags


cdef class ROM:
    cdef Header header
    cdef bytes prg_rom
