from common.addressing import Addressing, argument_size


class Op:
    def __init__(self, opcode: int, mnemonic: str, addressing: Addressing):
        self.opcode = opcode
        self.mnemonic = mnemonic
        self.size = argument_size(addressing) + 1
        self.addressing = addressing


ops = [
    Op(0x10, "bpl", Addressing.RELATIVE),
    Op(0x20, "jsr", Addressing.ABSOLUTE),
    Op(0x2C, "bit", Addressing.ABSOLUTE),
    Op(0x78, "sei", Addressing.IMPLICIT),
    Op(0x8D, "sta", Addressing.ABSOLUTE),
    Op(0xA9, "lda", Addressing.IMMEDIATE),
]
ops_by_code = {op.opcode: op for op in ops}