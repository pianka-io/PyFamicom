from com.constants cimport STACK_OFFSET
from cpu.memory cimport Memory
from cpu.registers cimport Registers


cdef class Stack:
    def __init__(self, registers: Registers, memory: Memory):
        self.registers = registers
        self.memory = memory

        self.registers.SP = STACK_OFFSET

    cdef void push(self, int value) nogil:
        # print(f"push {value:x} @ {self.registers.SP:x}")
        cdef int sp = self.registers.SP
        self.memory.write_byte(sp, value & 0xFF)
        cdef int next = self.registers.SP - 1
        self.registers.SP = next

    cdef int pull(self) nogil:
        cdef int sp = self.registers.SP + 1
        self.registers.SP = sp
        cdef int value = self.memory.read_byte(sp)
        # print(f"pull {value:x} @ {self.registers.SP:x}")
        return value
