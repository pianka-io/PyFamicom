from time import sleep
from typing import Optional
import pygame
from com.constants import TV_WIDTH, TV_HEIGHT, TV_SCALE
from tv.frame import Frame


class TV:
    BLACK = (0, 0, 0)

    def __init__(self):
        self.running = False
        self.frame: Optional[Frame] = None

    def start(self):
        pygame.init()

        # Create screen and surface for fast pixel updates
        screen = pygame.display.set_mode((TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
        pygame.display.set_caption("PyFamicom")
        pixel_surface = pygame.Surface((TV_WIDTH, TV_HEIGHT))

        self.running = True
        while self.running:
            # Limit loop to ~60 FPS
            pygame.time.delay(16)

            # Handle events
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False

            # Fill pixel surface with frame data
            if self.frame:
                for y in range(TV_HEIGHT):
                    for x in range(TV_WIDTH):
                        r, g, b = self.frame.read_pixel(x, y)
                        pixel_surface.set_at((x, y), (r, g, b))

            # Scale pixel surface and blit to screen
            scaled_surface = pygame.transform.scale(pixel_surface, (TV_WIDTH * TV_SCALE, TV_HEIGHT * TV_SCALE))
            screen.blit(scaled_surface, (0, 0))

            # Update the display
            pygame.display.flip()

        pygame.quit()
