from __future__ import annotations

from typing import Final

from textual import on
from textual.containers import Horizontal, Vertical, Container
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Static, Button
from textual.reactive import var

from measuremnts_container import Measurements

"""from control_functions.control_file import calculate_window_opening
from control_functions.window_functions import open_window, close_window"""

OPEN_WINDOW_PIN: Final[int] = 20
CLOSE_WINDOW_PIN: Final[int] = 21


class ManualMode(Vertical):
    DEFAULT_CSS = """
    #mode-1-static {
        background: rgb(150, 120, 251);
    }

    #mode-2-static {
        background: rgb(100, 91, 211);
    }

    #mode-3-static {
        background: rgb(92, 10, 200);
    }

    """

    def compose(self) -> ComposeResult:
        with Horizontal(id="auto-mode-choose"):
            yield Button("Close", id="close-button")
            yield Button("Mode 1", id="mode1-button")
            yield Button("Mode 2", id="mode2-button")
            yield Button("Mode 3", id="mode3-button")
        yield Static("Mode 1 -> opens window for 3 seconds", id="mode-1-static")
        yield Static("Mode 2 -> opens window for 6 seconds", id="mode-2-static")
        yield Static("Mode 3 -> opens window for 9 seconds", id="mode-3-static")


class ModeChoose(Horizontal):
    mode_auto: bool = var(False)
    """mode_auto is var to detect mode that is currently set"""

    def compose(self) -> ComposeResult:
        yield Button("Auto", id="auto-mode-button")
        yield Button("Manual", id="manual-mode-button")

    @on(Button.Pressed)
    def change_mode(self, event: Button.Pressed) -> None:
        show_mode_static = self.app.query_one("#show-mode")
        manual_container = self.app.query_one(ManualMode)

        if event.button.id == "auto-mode-button":
            self.mode_auto = True
            show_mode_static.update("Mode: auto")
            manual_container.display = False
            return
        self.mode_auto = False
        show_mode_static.update("Mode: manual")
        manual_container.display = True
        return


class ControlWindowPosition(Container):
    """Container that control and displays position of the window"""

    window_position: int = var(0)
    """
    window_position = 0 -> close
    window_position = 1 -> open in mode 1
    etc.
    """

    def compose(self) -> ComposeResult:
        yield Static(f"Window position: {self.window_position}")


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

    def __init__(self) -> None:
        super().__init__()
        self.__manual_container = ManualMode()
        self.__manual_container.display = False

        self.__measurements_container = Measurements()
        self.__mode_choose_container = ModeChoose()
        self.__window_position_container = ControlWindowPosition()

    def compose(self) -> ComposeResult:
        yield Header()
        yield self.__window_position_container
        yield Static("Mode: auto", id="show-mode")
        yield self.__mode_choose_container
        yield self.__measurements_container
        yield self.__manual_container
        yield Footer()

    def on_mount(self) -> None:
        self.manual_mode()
        self.set_interval(30, self.manual_mode)

    def manual_mode(self) -> None:
        """Method to perform automation window openning"""
        if not self.__mode_choose_container.mode_auto:
            return

        """mode_to_execute = calculate_window_opening()

        if mode_to_execute[1] == self.window_position:
            return

        if not mode_to_execute[0]:
            close_window(pin=CLOSE_WINDOW_PIN, closing_time=self.window_position * 3)
            return

        if mode_to_execute[1] > self.window_position:
            open_window(
                pin=OPEN_WINDOW_PIN, mode=mode_to_execute[1] - self.window_position
            )

        else:
            close_window(
                pin=CLOSE_WINDOW_PIN,
                closing_time=(self.window_position - mode_to_execute[1]) * 3,
            )
    """


if __name__ == "__main__":
    app = ComputerRoomApp()
    app.run()
