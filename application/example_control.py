import RPi.GPIO as GPIO

from time import sleep


def open_window(pin: int, openning_time: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is connected to the motor driver.d
    """
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(pin, GPIO.OUT)

    GPIO.output(pin, GPIO.HIGH)
    sleep(openning_time)
    GPIO.output(pin, GPIO.LOW)
    GPIO.cleanup()


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


open_window(16, 9)
close_window(17, 9)
