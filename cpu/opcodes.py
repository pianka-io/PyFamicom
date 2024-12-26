from common.addressing import Addressing, argument_size
from common.utilities import signed_byte


class Op:
    def __init__(self, opcode: int, mnemonic: str, addressing: Addressing, cycles: int):
        self.opcode = opcode
        self.mnemonic = mnemonic
        self.size = argument_size(addressing) + 1
        self.addressing = addressing
        self.cycles = cycles

    def assembler(self, arg: int) -> str:
        arg_asm = f"${arg:x}"
        match self.addressing:
            case Addressing.IMPLICIT:
                arg_asm = ""
            case Addressing.IMMEDIATE:
                arg_asm = f"#{arg_asm}"
            case Addressing.ZERO_X:
                arg_asm = f"#{arg_asm},X"
            case Addressing.ZERO_Y:
                arg_asm = f"#{arg_asm},Y"
            case Addressing.RELATIVE:
                delta = signed_byte(arg)
                plus = "+" if delta >= 0 else ""
                arg_asm = f"*{plus}{delta:x}"
            case Addressing.ABSOLUTE_X:
                arg_asm = f"{arg_asm},X"
            case Addressing.ABSOLUTE_Y:
                arg_asm = f"{arg_asm},Y"
            case Addressing.INDIRECT:
                arg_asm = f"({arg_asm})"
            case Addressing.INDEXED_INDIRECT:
                arg_asm = f"({arg_asm},X)"
            case Addressing.INDIRECT_INDEXED:
                arg_asm = f"({arg_asm}),Y"
        return f"{self.mnemonic}:{self.size} {arg_asm}"


ops = [
    Op(0x10, "bpl", Addressing.RELATIVE, 2),
    Op(0x18, "clc", Addressing.IMPLICIT, 2),
    Op(0x20, "jsr", Addressing.ABSOLUTE, 6),
    Op(0x29, "and", Addressing.IMMEDIATE, 2),
    Op(0x2C, "bit", Addressing.ABSOLUTE, 4),
    Op(0x48, "pha", Addressing.IMPLICIT, 3),
    Op(0x40, "rti", Addressing.IMPLICIT, 6),
    Op(0x4C, "jmp", Addressing.ABSOLUTE, 3),
    Op(0x60, "rts", Addressing.IMPLICIT, 6),
    Op(0x68, "pla", Addressing.IMPLICIT, 4),
    Op(0x69, "adc", Addressing.IMMEDIATE, 2),
    Op(0x78, "sei", Addressing.IMPLICIT, 2),
    Op(0x88, "dey", Addressing.IMPLICIT, 2),
    Op(0x8A, "txa", Addressing.IMPLICIT, 2),
    Op(0x8D, "sta", Addressing.ABSOLUTE, 4),
    Op(0x85, "sta", Addressing.ZERO, 3),
    Op(0x86, "stx", Addressing.ZERO, 3),
    Op(0x8E, "stx", Addressing.ABSOLUTE, 4),
    Op(0x84, "sty", Addressing.ZERO, 3),
    Op(0x98, "tya", Addressing.IMPLICIT, 2),
    Op(0xA2, "ldx", Addressing.IMMEDIATE, 2),
    Op(0xA0, "ldy", Addressing.IMMEDIATE, 2),
    Op(0xA5, "lda", Addressing.ZERO, 3),
    Op(0xA8, "tay", Addressing.IMPLICIT, 2),
    Op(0xAA, "tax", Addressing.IMPLICIT, 2),
    Op(0xA9, "lda", Addressing.IMMEDIATE, 2),
    Op(0xAD, "lda", Addressing.ABSOLUTE, 4),
    Op(0xB1, "lda", Addressing.INDIRECT_INDEXED, 5),
    Op(0xBD, "lda", Addressing.ABSOLUTE_X, 4),
    Op(0xC5, "cmp", Addressing.ZERO, 3),
    Op(0xC9, "cmp", Addressing.IMMEDIATE, 2),
    Op(0xC8, "iny", Addressing.IMPLICIT, 2),
    Op(0xCA, "dex", Addressing.IMPLICIT, 2),
    Op(0xCD, "cmp", Addressing.ABSOLUTE, 4),
    Op(0xD0, "bne", Addressing.RELATIVE, 2),
    Op(0xE6, "inc", Addressing.ZERO, 5),
    Op(0xE8, "inx", Addressing.IMPLICIT, 2),
    Op(0xEE, "inc", Addressing.ABSOLUTE, 6),
    Op(0xC6, "dec", Addressing.ZERO, 5),
    Op(0xEA, "nop", Addressing.IMPLICIT, 2),
    Op(0xF0, "beq", Addressing.RELATIVE, 2)
]
ops_by_code = {op.opcode: op for op in ops}
