"""File with functions to close or open window"""
from time import sleep

import RPi.GPIO as GPIO


def open_window(mode: int, pin: int) -> None:
    """
    Parameters
    -------------
    mode: put 1 to open window for 9 seconds, or put 2 to open window for 18 seconds.
    pin: the GPIO pin number that is connected to the motor driver.d
    """
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)

    if mode == 1:
        GPIO.output(pin, GPIO.HIGH)
        sleep(3)
        GPIO.output(pin, GPIO.LOW)
        GPIO.cleanup()
    elif mode == 2:
        GPIO.output(pin, GPIO.HIGH)
        sleep(6)
        GPIO.output(pin, GPIO.LOW)
        GPIO.cleanup()
    elif mode == 3:
        GPIO.output(pin, GPIO.HIGH)
        sleep(9)
        GPIO.output(pin, GPIO.LOW)
        GPIO.cleanup()
    else:
        GPIO.cleanup()
        raise ValueError("Invalid mode number ! You had to selected 1 or 2 !")


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
