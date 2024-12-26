from collections.abc import Callable
from typing import Optional


class Interrupt:
    def __init__(self):
        self.callback: Optional[Callable] = None

    def register(self, callback: Callable):
        self.callback = callback

    def trigger(self):
        if self.callback is not None:
            self.callback()
