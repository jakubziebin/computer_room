from __future__ import annotations

from typing import Final
from time import sleep

from textual import on
from textual.containers import Horizontal
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Button
from textual.reactive import var

import RPi.GPIO as GPIO

OPEN_WINDOW_PIN: Final[int] = 20
CLOSE_WINDOW_PIN: Final[int] = 16


def open_window(pin: int, openning_time: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is connected to the motor driver.d
    """
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)

    GPIO.output(pin, GPIO.HIGH)
    sleep(open_window)
    GPIO.output(pin, GPIO.LOW)
    GPIO.cleanup()


def close_window(pin: int, closing_time: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is responsible for closing the window.
    """
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)

    GPIO.output(pin, GPIO.HIGH)
    sleep(closing_time)
    GPIO.output(pin, GPIO.LOW)

    GPIO.cleanup()


class ComputerRoomApp(App):
    DEFAULT_CSS = """
    Button {
        height: 12;
        width: 20;
        margin-left: 2;
        margin-right: 2;
    }

    Horizontal {
        align: center middle;
        width: 1fr;
    }
    """

    window_position: int = var(0)

    def compose(self) -> ComposeResult:
        yield Header()
        with Horizontal(id="mode-choose-container"):
            yield Button("Close", id="mode-0")
            yield Button("Open", id="mode-1")
        yield Footer()

    @on(Button.Pressed, "#mode-0")
    def close_window(self, event: Button.Pressed) -> None:
        if self.window_position == 0:
            return
        self.window_position = 0
        close_window(CLOSE_WINDOW_PIN, 9)

    @on(Button.Pressed, "#mode-1")
    def open_window(self, event: Button.Pressed) -> None:
        if self.window_position == 1:
            return
        self.window_position = 1
        open_window(OPEN_WINDOW_PIN, 9)


if __name__ == "__main__":
    app = ComputerRoomApp()
    app.run()
