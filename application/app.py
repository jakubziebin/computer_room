from __future__ import annotations

from typing import Final

from textual import on
from textual.containers import Horizontal
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Static, Button
from textual.reactive import var

from measuremnts_container import Measurements

from control_functions.control_file import calculate_window_opening
from control_functions.window_functions import open_window, close_window

OPEN_WINDOW_PIN: Final[int] = 20
CLOSE_WINDOW_PIN: Final[int] = 16


class ComputerRoomApp(App):
    DEFAULT_CSS = """
    Button {
        margin-left: 2;
        margin-right: 2;
    }

    ControlWindowPosition {
        margin-top: 1;
        margin-bottom: 1;
        width: 1fr;
        background: rgb(56, 32, 21);
        height: 1;
    }

    Static {
        text-align: center;
        text-style: bold;
        width: 1fr;
    }

    Horizontal {
        align: center top;
    }

    #show-mode {
        background: rgb(20, 30, 144);
    }
    """

    window_position: int = var(0)
    auto_mode: bool = var(True)

    def __init__(self) -> None:
        super().__init__()
        self.__measurements_container = Measurements()

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("Mode: auto", id="show-mode")
        yield Static(
            f"Window position: {self.window_position}", id="window-position-display"
        )
        with Horizontal(id="mode-choose"):
            yield Button("Auto", id="auto-mode-button")
            yield Button("Manual", id="manual-mode-button")
        with Horizontal(id="mode-choose-container", disabled=True):
            yield Button("Close", id="mode-0")
            yield Button("Open", id="mode-1")
        yield Footer()

    def on_mount(self) -> None:
        self.auto_mode()
        self.set_interval(30, self.auto_mode)

    def auto_mode(self) -> None:
        """Method to perform automation window openning"""
        if not self.auto_mode:
            return

        mode_to_execute = calculate_window_opening(
            temperature=self.__measurements_container.temperature,
            humidity=self.__measurements_container.humidity,
            co2=self.__measurements_container.co2,
        )

        if mode_to_execute == self.window_position:
            return

        if mode_to_execute == 1:
            open_window(pin=OPEN_WINDOW_PIN, openning_time=9)
            self.window_position += 1

        if mode_to_execute == 0:
            close_window(pin=CLOSE_WINDOW_PIN, closing_time=9)
            self.window_position -= 1

    @on(Button.Pressed)
    def move_window(self, event: Button.Pressed) -> None:
        if event.button.id.split("-")[1] == "mode":
            mode_choose_container = self.app.query_one("#mode-choose-container")
            if event.button.id == "auto-mode-button":
                mode_choose_container.disabled = True
                self.app.query_one("#show-mode").update("Mode: auto")
                return

            mode_choose_container.disabled = False
            self.app.query_one("#show-mode").update("Mode: manual")

            return

        mode_to_execute = int(event.button.id.split("-")[1])

        if self.window_position == mode_to_execute:
            return

        if mode_to_execute == 0:
            close_window(pin=CLOSE_WINDOW_PIN, closing_time=9)
            self.window_position -= 1
            self.app.query_one("#window-position-display").update(
                f"Window position {self.window_position}"
            )
            return

        if mode_to_execute == 1:
            open_window(pin=OPEN_WINDOW_PIN, openning_time=9)
            self.window_position += 1
            self.app.query_one("#window-position-display").update(
                f"Window position {self.window_position}"
            )
            return


if __name__ == "__main__":
    app = ComputerRoomApp()
    app.run()
