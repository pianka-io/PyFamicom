from common.addressing import Addressing


class Op:
    def __init__(self, opcode: int, mnemonic: str, size: int, addressing: Addressing):
        self.opcode = opcode
        self.mnemonic = mnemonic
        self.size = size
        self.addressing = addressing


ops = [
    Op(0x20, "jsr", 3, Addressing.ABSOLUTE),
    Op(0x78, "sei", 1, Addressing.IMPLICIT),
    Op(0x8D, "sta", 3, Addressing.ABSOLUTE),
    Op(0xA9, "lda", 2, Addressing.IMMEDIATE)
]
ops_by_code = {op.opcode: op for op in ops}