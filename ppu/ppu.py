from time import sleep

from common.interrupt import Interrupt
from ppu.memory import Memory
from ppu.registers import Registers


class PPU:
    def __init__(self, nmi: Interrupt):
        self.running = False
        self.nmi = nmi
        self.memory = Memory()
        self.registers = Registers(self.memory)
        self.counter = 0

    def start(self):
        self.running = True
        while self.running:
            self.registers.set_vblank()
            self.nmi.trigger()
            sleep(0.01667)
            self.registers.clear_vblank()
            self.render()

    def stop(self):
        self.running = False

    def render(self):
        self.counter += 1
        # if self.counter >= 60:
        #     self.counter = 0
        #     print("start")
        #     print(self.registers.name_table)
        #     for y in range(30):
        #         for x in range(32):
        #             base = self.registers.name_table
        #             offset = y * 32 + x
        #             address = base + offset
        #             value = self.memory.read_byte(address)
        #             print(f"{value:4x}", end="")
        #         print()
