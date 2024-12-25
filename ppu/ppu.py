from time import sleep

from ppu.registers import Registers


class PPU:
    def __init__(self):
        self.running = False
        self.registers = Registers()

    def start(self):
        self.running = True
        self.registers.set_vblank()
        while self.running:
            sleep(100)

    def stop(self):
        self.running = False
