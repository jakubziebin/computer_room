from __future__ import annotations

from textual.app import ComposeResult
from textual.containers import Horizontal
from textual.widgets import Static

from measurements_functions.measurement_temperature_humidity import read_dht_values


class Measurement(Horizontal):
    """This class displays one measured value"""

    def __init__(self, value: float, *, name_of_value: str, unit: str) -> None:
        super().__init__(id=f"{name_of_value}-container")
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

    def __init__(self):
        super().__init__()
        self.__dht_values = read_dht_values(4, 17)

        self.__temperature = (
            self.__dht_values.get("temperature_4", 20)
            + self.__dht_values.get("temperature_17", 20)
        ) // 2
        self.__humidity = (
            self.__dht_values.get("humidity_4", 30)
            + self.__dht_values.get("humidity_17", 30)
        ) // 2

    def compose(self) -> ComposeResult:
        yield Measurement(self.temperature, name_of_value="temperature", unit="°C")
        yield Measurement(self.humidity, name_of_value="humidity", unit="%")
        yield Measurement(self.co2, name_of_value="co2", unit="ppm")

    def on_mount(self) -> None:
        self.update_displaying_values()
        self.set_interval(10, self.update_displaying_values)

    def update_displaying_values(self) -> None:
        self.query("*").remove()

        self.__dht_values = read_dht_values(4, 17)
        self.__temperature = (
            self.__dht_values["temperature_4"] + self.__dht_values["temperature_17"]
        ) // 2
        self.__humidity = (
            self.__dht_values["humidity_4"] + self.__dht_values["humidity_17"]
        ) // 2

        self.mount(
            Measurement(self.temperature, name_of_value="temperature", unit="°C")
        )
        self.mount(Measurement(self.humidity, name_of_value="humidity", unit="%"))
        self.mount(Measurement(self.co2, name_of_value="co2", unit="ppm"))

    @property
    def temperature(self) -> int:
        return self.__temperature

    @property
    def humidity(self) -> int:
        return self.__humidity

    @property
    def co2(self) -> float:
        return 333.333
