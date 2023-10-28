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

    #buttons-container {
        align: center top;
    }

    #show-mode {
        text-align: center;
        width: 1fr;
        background: rgb(20, 30, 144);
        text-style: bold;
    }
    """

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("Mode: auto", id="show-mode")
        with Horizontal(id="buttons-container"):
            yield Button("Auto", id="auto-mode-button")
            yield Button("Manual", id="manual-mode-button")
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
