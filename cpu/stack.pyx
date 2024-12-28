from com.constants cimport STACK_OFFSET
from cpu.memory cimport Memory
from cpu.registers cimport Registers


cdef class Stack:
    def __init__(self, registers: Registers, memory: Memory):
        self.registers = registers
        self.memory = memory

        self.registers.SP = STACK_OFFSET

    cdef push(self, int value):
        # print(f"push {value:x} @ {self.registers.SP:x}")
        sp = self.registers.SP
        self.memory.write_byte(sp, value & 0xFF)
        self.registers.SP -= 1

    cdef int pull(self):
        sp = self.registers.SP + 1
        self.registers.SP = sp
        value = self.memory.read_byte(sp)
        # print(f"pull {value:x} @ {self.registers.SP:x}")
        return value
