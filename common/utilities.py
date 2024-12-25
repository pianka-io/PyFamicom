def signed_byte(value: int) -> int:
    if value > 127:
        return value - 256
    else:
        return value
