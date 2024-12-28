from cpu.registers cimport Registers
from cpu.memory cimport Memory

cdef class Stack:
    cdef Registers registers
    cdef Memory memory

    cdef push(self, int value)
    cdef int pull(self)