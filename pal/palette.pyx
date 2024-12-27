class Palette:
    def __init__(self, colors: bytes):
        self.colors = colors

    @staticmethod
    def load(path: str):
        with open(path, 'rb') as file:
            colors = file.read()

        return Palette(colors)

    def color(self, index: int) -> (int, int, int):
        offset = index * 3
        return tuple(self.colors[offset:offset+3])
