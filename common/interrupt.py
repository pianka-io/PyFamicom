class Interrupt:
    def __init__(self):
        self.__triggered = False

    def trigger(self):
        self.__triggered = True

    def active(self):
        return self.__triggered

    def clear(self):
        self.__triggered = False
