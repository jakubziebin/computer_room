"""File with functions to close or open window"""
from time import sleep

import RPi.GPIO as GPIO


def open_window(pin: int, openning_time: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is connected to the motor driver.d
    """
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)

    if isinstance(openning_time, int):
        GPIO.output(pin, GPIO.HIGH)
        sleep(openning_time)
        GPIO.output(pin, GPIO.LOW)
        GPIO.cleanup()
    else:
        GPIO.cleanup()
        raise ValueError("Invalid time number !")


def close_window(pin: int, closing_time: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is responsible for closing the window.
    """
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)

    GPIO.output(pin, GPIO.HIGH)
    sleep(closing_time)
    GPIO.output(pin, GPIO.LOW)

    GPIO.cleanup()
