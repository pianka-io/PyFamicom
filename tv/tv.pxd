from tv.frame cimport Frame

cdef class TV:
    cdef bint running
    cdef Frame frame

    cdef start(self)