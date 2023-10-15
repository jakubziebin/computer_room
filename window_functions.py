"""File with functions to close or open window"""
from time import sleep

import RPi.GPIO as GPIO


def open_window(mode: int, pin: int) -> None:
    """
    Parameters
    -------------
    mode: put 1 to open window for 9 seconds, or put 2 to open window for 18 seconds.
    pin: the GPIO pin number that is connected to the motor driver.
    """
    if mode == 1:
        GPIO.output(pin, GPIO.HIGH)
        sleep(9)
        GPIO.output(pin, GPIO.LOW)
    elif mode == 2:
        GPIO.output(pin, GPIO.HIGH)
        sleep(18)
        GPIO.output(pin, GPIO.LOW)
    else:
        raise ValueError("Invalid mode number ! You had to selected 1 or 2 !")


def close_window(pin: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is responsible for closing the window.
    """
    GPIO.output(pin, GPIO.HIGH)
    sleep(9)
    GPIO.output(pin, GPIO.LOW)
