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
    return False, 0
