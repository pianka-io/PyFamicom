# from com.addressing cimport argument_size, ADDR_IMPLICIT, ADDR_IMMEDIATE, ADDR_ZERO_X, ADDR_ZERO_Y, ADDR_RELATIVE, \
#     ADDR_ABSOLUTE_X, ADDR_ABSOLUTE_Y, ADDR_INDIRECT, ADDR_INDEXED_INDIRECT, ADDR_INDIRECT_INDEXED, ADDR_ABSOLUTE, \
#     ADDR_ZERO
# from com.utilities cimport signed_byte
#
#
# cdef class Op:
#     def __init__(self, opcode: int, mnemonic: str, addressing: int, cycles: int):
#         self.opcode = opcode
#         self.mnemonic = mnemonic
#         self.size = argument_size(addressing) + 1
#         self.addressing = addressing
#         self.cycles = cycles
#
#     cdef str assembler(self, int arg):
#         arg_asm = f"${arg:x}"
#         if self.addressing == ADDR_IMPLICIT:
#             arg_asm = ""
#         elif self.addressing == ADDR_IMMEDIATE:
#             arg_asm = f"#{arg_asm}"
#         elif self.addressing == ADDR_ZERO_X:
#             arg_asm = f"#{arg_asm},X"
#         elif self.addressing == ADDR_ZERO_Y:
#             arg_asm = f"#{arg_asm},Y"
#         elif self.addressing == ADDR_RELATIVE:
#             delta = signed_byte(arg)
#             plus = "+" if delta >= 0 else ""
#             arg_asm = f"*{plus}{delta:x}"
#         elif self.addressing == ADDR_ABSOLUTE_X:
#             arg_asm = f"{arg_asm},X"
#         elif self.addressing == ADDR_ABSOLUTE_Y:
#             arg_asm = f"{arg_asm},Y"
#         elif self.addressing == ADDR_INDIRECT:
#             arg_asm = f"({arg_asm})"
#         elif self.addressing == ADDR_INDEXED_INDIRECT:
#             arg_asm = f"({arg_asm},X)"
#         elif self.addressing == ADDR_INDIRECT_INDEXED:
#             arg_asm = f"({arg_asm}),Y"
#         return f"{self.mnemonic}:{self.size} {arg_asm}"
#
#
# cdef
#
# # ops[0x10] = Op(0x10, "bpl", ADDR_RELATIVE, 2)
# # ops[0x18] = Op(0x18, "clc", ADDR_IMPLICIT, 2)
# # ops[0x20] = Op(0x20, "jsr", ADDR_ABSOLUTE, 6)
# # ops[0x29] = Op(0x29, "and", ADDR_IMMEDIATE, 2)
# # ops[0x2C] = Op(0x2C, "bit", ADDR_ABSOLUTE, 4)
# # ops[0x48] = Op(0x48, "pha", ADDR_IMPLICIT, 3)
# # ops[0x40] = Op(0x40, "rti", ADDR_IMPLICIT, 6)
# # ops[0x4C] = Op(0x4C, "jmp", ADDR_ABSOLUTE, 3)
# # ops[0x60] = Op(0x60, "rts", ADDR_IMPLICIT, 6)
# # ops[0x68] = Op(0x68, "pla", ADDR_IMPLICIT, 4)
# # ops[0x69] = Op(0x69, "adc", ADDR_IMMEDIATE, 2)
# # ops[0x78] = Op(0x78, "sei", ADDR_IMPLICIT, 2)
# # ops[0x88] = Op(0x88, "dey", ADDR_IMPLICIT, 2)
# # ops[0x8A] = Op(0x8A, "txa", ADDR_IMPLICIT, 2)
# # ops[0x8D] = Op(0x8D, "sta", ADDR_ABSOLUTE, 4)
# # ops[0x85] = Op(0x85, "sta", ADDR_ZERO, 3)
# # ops[0x86] = Op(0x86, "stx", ADDR_ZERO, 3)
# # ops[0x8E] = Op(0x8E, "stx", ADDR_ABSOLUTE, 4)
# # ops[0x84] = Op(0x84, "sty", ADDR_ZERO, 3)
# # ops[0x90] = Op(0x90, "bcc", ADDR_RELATIVE, 2)
# # ops[0x98] = Op(0x98, "tya", ADDR_IMPLICIT, 2)
# # ops[0xA2] = Op(0xA2, "ldx", ADDR_IMMEDIATE, 2)
# # ops[0xA0] = Op(0xA0, "ldy", ADDR_IMMEDIATE, 2)
# # ops[0xA5] = Op(0xA5, "lda", ADDR_ZERO, 3)
# # ops[0xA8] = Op(0xA8, "tay", ADDR_IMPLICIT, 2)
# # ops[0xAA] = Op(0xAA, "tax", ADDR_IMPLICIT, 2)
# # ops[0xA9] = Op(0xA9, "lda", ADDR_IMMEDIATE, 2)
# # ops[0xAD] = Op(0xAD, "lda", ADDR_ABSOLUTE, 4)
# # ops[0xB1] = Op(0xB1, "lda", ADDR_INDIRECT_INDEXED, 5)
# # ops[0xBD] = Op(0xBD, "lda", ADDR_ABSOLUTE_X, 4)
# # ops[0xC5] = Op(0xC5, "cmp", ADDR_ZERO, 3)
# # ops[0xC9] = Op(0xC9, "cmp", ADDR_IMMEDIATE, 2)
# # ops[0xC8] = Op(0xC8, "iny", ADDR_IMPLICIT, 2)
# # ops[0xCA] = Op(0xCA, "dex", ADDR_IMPLICIT, 2)
# # ops[0xCD] = Op(0xCD, "cmp", ADDR_ABSOLUTE, 4)
# # ops[0xD0] = Op(0xD0, "bne", ADDR_RELATIVE, 2)
# # ops[0xE6] = Op(0xE6, "inc", ADDR_ZERO, 5)
# # ops[0xE8] = Op(0xE8, "inx", ADDR_IMPLICIT, 2)
# # ops[0xEE] = Op(0xEE, "inc", ADDR_ABSOLUTE, 6)
# # ops[0xC6] = Op(0xC6, "dec", ADDR_ZERO, 5)
# # ops[0xEA] = Op(0xEA, "nop", ADDR_IMPLICIT, 2)
# # ops[0xF0] = Op(0xF0, "beq", ADDR_RELATIVE, 2)
# # ops[0x49] = Op(0x49, "eor", ADDR_IMMEDIATE, 2)
# # ops[0x38] = Op(0x38, "sec", ADDR_IMPLICIT, 2)
