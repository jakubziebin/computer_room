from __future__ import annotations

from textual.app import ComposeResult
from textual.containers import Horizontal
from textual.widgets import Static


class Measurement(Horizontal):
    """This class displays one measured value"""

    def __init__(self, value: float, *, name_of_value: str, unit: str) -> None:
        super().__init__()
        self.__value = value
        self.__name_of_value = name_of_value
        self.__unit = unit

    def compose(self) -> ComposeResult:
        yield Static(
            self.__name_of_value.capitalize(), id=f"{self.__name_of_value}-label"
        )
        yield Static(
            f"{self.__value} {self.__unit}", id=f"{self.__name_of_value}-value"
        )


class Measurements(Horizontal):
    DEFAULT_CSS = """
    #temperature-label {
        background: rgb(120, 10, 32);
    }

    #co2-label {
        background: rgb(10, 120, 32);
    }

    #humidity-label {
        background: rgb(10, 32, 120);
    }
    """

    """
    This class represents a set of measured values for temperature, humidity
    and CO2 levels.

    Access to temperature, humidity, and CO2 values is managed through properties,
    so you can access them like this:

    Usage:
    >>> data = Measurements()
    >>> temperature = data.temperature
    >>> humidity = data.humidity
    >>> co2_level = data.co2
    """

    def compose(self) -> ComposeResult:
        yield Measurement(self.temperature, name_of_value="temperature", unit="°C")
        yield Measurement(self.humidity, name_of_value="humidity", unit="%")
        yield Measurement(self.c02, name_of_value="co2", unit="ppm")

    @property
    def temperature(self) -> float:
        return 24.0

    @property
    def humidity(self) -> float:
        return 50.0

    @property
    def c02(self) -> float:
        return 333.333
