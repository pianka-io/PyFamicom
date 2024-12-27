class Clock:
    def __init__(self):
        self.cpu_cycles = 0
        self.ppu_cycles = 0

    def cpu_ready(self):
        return True

    def ppu_ready(self):
        return self.ppu_cycles >= self.cpu_cycles * 3
