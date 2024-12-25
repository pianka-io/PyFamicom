from common.addressing import Addressing, argument_size
from common.utilities import signed_byte


class Op:
    def __init__(self, opcode: int, mnemonic: str, addressing: Addressing):
        self.opcode = opcode
        self.mnemonic = mnemonic
        self.size = argument_size(addressing) + 1
        self.addressing = addressing

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
        return f"{self.mnemonic} {arg_asm}"


ops = [
    Op(0x10, "bpl", Addressing.RELATIVE),
    Op(0x20, "jsr", Addressing.ABSOLUTE),
    Op(0x2C, "bit", Addressing.ABSOLUTE),
    Op(0x60, "rts", Addressing.IMPLICIT),
    Op(0x78, "sei", Addressing.IMPLICIT),
    Op(0x8D, "sta", Addressing.ABSOLUTE),
    Op(0x85, "sta", Addressing.ZERO),
    Op(0xA9, "lda", Addressing.IMMEDIATE),
]
ops_by_code = {op.opcode: op for op in ops}