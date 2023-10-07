"""File with functions to perform basic control of actuator"""
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


if __name__ == "__main__":
    open_window_pin = 13  # change pin number after connected to raspberry !!!!
    open_window_mode = 1  # mode will be changed by app in future

    close_window_pin = 14  # change pin number after connection !!!!

    time_between_open_close = 30  # use only for testing

    # setting all used pins as output
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(open_window_pin, GPIO.OUT)
    GPIO.setup(close_window_pin, GPIO.OUT)

    try:
        open_window_pin(mode=1, pin=open_window)
        sleep(time_between_open_close)
        close_window(pin=close_window_pin)
    except (ValueError, TypeError):
        print("Program must be restarted due to error:")
        raise

    GPIO.cleanup()
