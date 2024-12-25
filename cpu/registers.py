class Registers:
    def __init__(self):
        self.A = 0
        self.X = 0
        self.Y = 0

        self.P = 0
        self.SP = 0
        self.PC = 0

    def is_p(self, flag: int) -> bool:
        return self.P & flag == flag

    def set_p(self, flag: int):
        self.P |= flag

    def unset_p(self, flag: int):
        self.P &= ~flag
