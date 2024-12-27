import pygame
import sys

from common.constants import TV_WIDTH, TV_HEIGHT, TV_SCALE


class TV:
    def __init__(self):
        self.running = False

    def start(self):
        pygame.init()

        screen = pygame.display.set_mode((TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
        pygame.display.set_caption("PyFamicom")

        BLACK = (0, 0, 0)
        screen.fill(BLACK)
        # pixels = [[(BLACK, WHITE, RED)[(x % 3)] for x in range(WIDTH)] for y in range(HEIGHT)]

        self.running = True
        while self.running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False

            screen.fill(BLACK)

            for y in range(TV_HEIGHT):
                for x in range(TV_WIDTH):
                    ...
                    # color = pixels[y % HEIGHT][x % WIDTH]  # Example pixel data
                    # pygame.draw.rect(screen, color, (x * SCALE, y * SCALE, SCALE, SCALE))

            pygame.display.flip()

        pygame.quit()
