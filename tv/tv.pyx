from time import sleep

import pygame

from com.constants cimport TV_WIDTH, TV_HEIGHT, TV_SCALE
from com.pixel cimport Pixel


cdef class TV:
    def __init__(self):
        self.running = False
        pygame.init()
        pygame.display.set_caption("PyFamicom")
        self.screen = pygame.display.set_mode((TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
        self.pixel_surface = pygame.Surface((TV_WIDTH, TV_HEIGHT))

    cdef void tick(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False

        # sleep(0.1667)

        for y in range(TV_HEIGHT):
            for x in range(TV_WIDTH):
                color = self.read_pixel(x, y)
                self.pixel_surface.set_at((x, y), (color.r, color.g, color.b))

        scaled_surface = pygame.transform.scale(self.pixel_surface, (TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
        self.screen.blit(scaled_surface, (0, 0))
        pygame.display.flip()

        # pygame.quit()

    cdef void stop(self) nogil:
        self.running = False

    cdef Pixel read_pixel(self, int x, int y) noexcept nogil:
        cdef int index = (y * TV_WIDTH + x) * 3
        cdef Pixel pixel
        pixel.r = self.frame[index]
        pixel.g = self.frame[index + 1]
        pixel.b = self.frame[index + 2]
        return pixel
