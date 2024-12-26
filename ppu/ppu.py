from time import sleep

from common.interrupt import Interrupt
from ppu.registers import Registers


class PPU:
    def __init__(self, nmi: Interrupt):
        self.running = False
        self.nmi = nmi
        self.registers = Registers()

    def start(self):
        self.running = True
        while self.running:
            self.registers.set_vblank()
            self.nmi.trigger()
            sleep(0.01667)
            self.registers.clear_vblank()

    def stop(self):
        self.running = False
