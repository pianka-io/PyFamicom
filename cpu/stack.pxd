from cpu.registers cimport Registers
from cpu.memory cimport Memory

cdef class Stack:
    cdef Registers registers
    cdef Memory memory

    cdef void push(self, int value) nogil
    cdef int pull(self) nogil