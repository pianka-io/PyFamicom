from common.constants import TV_WIDTH, TV_HEIGHT


class Frame:
    def __init__(self):
        self.pixels = bytearray(TV_WIDTH * TV_HEIGHT * 3)

    def write_pixel(self, x: int, y: int, r: int, g: int, b: int):
        index = (y * TV_WIDTH + x) * 3
        self.pixels[index:index + 3] = [r, g, b]

    def read_pixel(self, x: int, y: int) -> (int, int, int):
        index = (y * TV_WIDTH + x) * 3
        return tuple(self.pixels[index:index + 3])
