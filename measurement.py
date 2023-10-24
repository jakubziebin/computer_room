"""File with functions to retrieve values from relevant sensors"""
from __future__ import annotations

import Adafruit_DHT as dht

"""
    After using functions from this file

    git clone https://github.com/adafruit/Adafruit_Python_DHT.git
    cd Adafruit_Python_DHT
    sudo apt-get update
    sudo apt-get install build-essential python-dev
    sudo python setup.py install
"""


def read_dht_values(*pins: int) -> dict[str, int] | None:
    """
    Returns a dictionary in the following format: {humidity_1: 49, temperature_1: 23}
    The number of humidities and temperatures depends on the number of pins provided.

    Parameters
    ----------
    *pins : int
    Include as many pin numbers as you have DHT sensors.
    """
    measurements = {}

    for pin in pins:
        humidity, temperature = dht.read_retry(dht.DHT22, pin)

        if humidity is not None and temperature is not None:
            measurements[f"humidity_{pin}"] = humidity
            measurements[f"temperature_{pin}"] = temperature
        else:
            print("Failed to get reading. Try again!")
            return

    return measurements
