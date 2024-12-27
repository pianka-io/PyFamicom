from typing import Optional
import pygame
import sys

from common.constants import TV_WIDTH, TV_HEIGHT, TV_SCALE
from tv.frame import Frame


class TV:
    def __init__(self):
        self.running = False
        self.frame: Optional[Frame] = None

    def start(self):
        pygame.init()

        screen = pygame.display.set_mode((TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
        pygame.display.set_caption("PyFamicom")

        BLACK = (0, 0, 0)
        screen.fill(BLACK)

        self.running = True
        while self.running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False

            screen.fill(BLACK)

            if self.frame:
                for y in range(TV_HEIGHT):
                    for x in range(TV_WIDTH):
                        r, g, b = self.frame.read_pixel(x, y)
                        color = (r, g, b)
                        pygame.draw.rect(
                            screen,
                            color,
                            (x * TV_SCALE, y * TV_SCALE, TV_SCALE, TV_SCALE)
                        )

            pygame.display.flip()
        pygame.quit()
