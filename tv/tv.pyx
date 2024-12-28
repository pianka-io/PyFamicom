from time import sleep

import pygame

from com.constants cimport TV_WIDTH, TV_HEIGHT, TV_SCALE
from tv.frame cimport Frame


cdef class TV:
    def __init__(self):
        self.running = False
        self.frame: Frame = Frame()

    cdef start(self):
        pygame.init()

        screen = pygame.display.set_mode((TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
        pygame.display.set_caption("PyFamicom")
        pixel_surface = pygame.Surface((TV_WIDTH, TV_HEIGHT))

        self.running = True
        while self.running:
            sleep(0)
            # pygame.time.delay(16)

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False

            if self.frame:
                for y in range(TV_HEIGHT):
                    for x in range(TV_WIDTH):
                        color = self.frame.read_pixel(x, y)
                        pixel_surface.set_at((x, y), (color.r, color.g, color.b))

            scaled_surface = pygame.transform.scale(pixel_surface, (TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
            screen.blit(scaled_surface, (0, 0))

            pygame.display.flip()

        pygame.quit()
