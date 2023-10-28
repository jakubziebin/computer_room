from __future__ import annotations

from textual.app import App, ComposeResult
from textual.widgets import Header, Footer


class ComputerRoomApp(App):
    def compose(self) -> ComposeResult:
        yield Header()
        yield Footer()


if __name__ == "__main__":
    app = ComputerRoomApp()
    app.run()
