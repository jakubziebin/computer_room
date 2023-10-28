from __future__ import annotations

from textual import on
from textual.containers import Horizontal
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Static, Button


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
        yield Footer()

    @on(Button.Pressed)
    def change_mode(self, event: Button.Pressed) -> None:
        pretty_widget = self.query_one("#show-mode")
        if event.button.id == "auto-mode-button":
            pretty_widget.update("Mode: auto")
            return
        pretty_widget.update("Mode: manual")
        return


if __name__ == "__main__":
    app = ComputerRoomApp()
    app.run()
