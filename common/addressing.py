from enum import Enum


class Addressing(Enum):
    IMPLICIT = 1
    ACCUMULATOR = 2
    IMMEDIATE = 3
    ZERO = 4
    ZERO_X = 5
    ZERO_Y = 6
    RELATIVE = 7
    ABSOLUTE = 8
    ABSOLUTE_X = 9
    ABSOLUTE_Y = 10
    INDIRECT = 11
    INDEXED_INDIRECT = 12
    INDIRECT_INDEXED = 13


def argument_size(addressing: Addressing) -> int:
    if addressing == Addressing.IMPLICIT:
        return 0
    if addressing in [Addressing.IMMEDIATE, Addressing.RELATIVE]:
        return 1
    if addressing in [Addressing.ABSOLUTE]:
        return 2
    raise ValueError(f"unsupported addressing mode: {addressing.name}")
