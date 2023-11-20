"""File with code to perform automation control of actuator"""
from ..measurements_functions.measurement_temperature_humidity import read_dht_values


def calculate_window_opening(
    temperature: int | float, humidity: int | float, co2: int | float
) -> int:
    """
    Returns
    ------------
    0 -> should not be open
    1 -> should be open
    """

    # pins to reading values from dht sensor
    # if it will be changed, just change the number

    pin_1 = 4
    pin_2 = 17
    dht_values = read_dht_values(pin_1, pin_2)

    temperature_outside = 24  # will be replaced by value from sensor

    difference_temperature_outside_inside = temperature - temperature_outside

    return 0
