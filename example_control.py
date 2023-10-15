"""File with functions to perform basic control of actuator"""
from time import sleep

import RPi.GPIO as GPIO

from .window_functions import open_window, close_window


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
