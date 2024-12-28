from time import sleep

import pygame

from com.constants cimport TV_WIDTH, TV_HEIGHT, TV_SCALE
from com.pixel cimport Pixel


cdef class TV:
    def __init__(self):
        self.running = False

    cdef start(self):
        pygame.init()

        screen = pygame.display.set_mode((TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
        pygame.display.set_caption("PyFamicom")
        pixel_surface = pygame.Surface((TV_WIDTH, TV_HEIGHT))

        self.running = True
        while self.running:
            # sleep(0.1)
            sleep(0.000423)

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False

            with nogil:
                for y in range(TV_HEIGHT):
                    for x in range(TV_WIDTH):
                        color = self.read_pixel(x, y)
                        with gil:
                            pixel_surface.set_at((x, y), (color.r, color.g, color.b))

            scaled_surface = pygame.transform.scale(pixel_surface, (TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
            screen.blit(scaled_surface, (0, 0))
            pygame.display.flip()

        pygame.quit()

    cdef Pixel read_pixel(self, int x, int y) noexcept nogil:
        cdef int index = (y * TV_WIDTH + x) * 3
        cdef Pixel pixel
        pixel.r = self.frame[index]
        pixel.g = self.frame[index + 1]
        pixel.b = self.frame[index + 2]
        return pixel
