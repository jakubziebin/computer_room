"""File with code to perform automation control of actuator"""


def calculate_window_opening() -> tuple[bool, int]:
    """
    Returns
    ------------
    tuple(is_window_should_be_open, mode)
    tuple(False, 0) -> should not be open
    tuple(True, 1) -> should be open in a mode 1
    tuple(True, 2) -> should be open in a mode 2
    tuple(True, 3) -> should be open in a mode 2
    """

    # pins to reading values from dht sensor
    # if it will be changed, just change the number

    """pin_1 = 4
    pin_2 = 17
    dht_values = read_dht_values(pin_1, pin_2)

    temperature_inside = (
        dht_values.get(f"temperature_{pin_1}", 20)
        + dht_values.get(f"temperature_{pin_1}", 20)
    ) // 2
    humidity_inside = (
        dht_values.get(f"humidity_{pin_1}", 35)
        + dht_values.get(f"humidity_{pin_1}", 35)
    ) // 2

    temperature_outside = 24  # will be replaced by value from sensor

    difference_temperature_outside_inside = temperature_inside - temperature_outside"""
    return False, 0
