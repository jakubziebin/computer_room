from __future__ import annotations

from textual import on
from textual.containers import Horizontal, Vertical
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Static, Button


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


class ComputerRoomApp(App):
    DEFAULT_CSS = """
    Button {
        margin-left: 2;
        margin-right: 2;
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

    #inside-temperature-display {
        background: rgb(32, 13, 54);
    }

     #inside-co2-display {
        background: rgb(78, 53, 123);
    }

    #inside-humidity-display {
        background: rgb(155, 32, 33);
    }
    """

    def __init__(self) -> None:
        super().__init__()
        self.__manual_container = ManualMode()
        self.__manual_container.display = False

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("Mode: auto", id="show-mode")
        with Horizontal(id="buttons-container"):
            yield Button("Auto", id="auto-mode-button")
            yield Button("Manual", id="manual-mode-button")
        with Horizontal(id="measaurment-data-container"):
            yield Static(
                "Current temperature inside: 24.0 °C", id="inside-temperature-display"
            )
            yield Static("Current C02 value inside: 330 ppm", id="inside-co2-display")
            yield Static("Current humidity inside: 50 %", id="inside-humidity-display")
        yield self.__manual_container
        yield Footer()

    @on(Button.Pressed)
    def change_mode(self, event: Button.Pressed) -> None:
        pretty_widget = self.query_one("#show-mode")
        if event.button.id == "auto-mode-button":
            pretty_widget.update("Mode: auto")
            self.__manual_container.display = False
            return
        pretty_widget.update("Mode: manual")
        self.__manual_container.display = True
        return


if __name__ == "__main__":
    app = ComputerRoomApp()
    app.run()
