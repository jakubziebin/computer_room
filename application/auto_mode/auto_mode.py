import time

import RPi.GPIO as GPIO
import Adafruit_DHT as dht

"""
    After using functions from this file

    git clone https://github.com/adafruit/Adafruit_Python_DHT.git
    cd Adafruit_Python_DHT
    sudo apt-get update
    sudo apt-get install build-essential python-dev
    sudo python setup.py install
"""
# Ustawienia pinu
SENSOR_DATA_PIN = 4

# Inicjalizacja GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(SENSOR_DATA_PIN, GPIO.IN)

# Zmienne przechowujące wartości czasów
pwmHighStartTicks = 0
pwmHighEndTicks = 0
pwmHighVal = 0
pwmLowVal = 0
flag = 0

# Funkcja obsługująca przerwanie
def interruptChange(channel):
    global pwmHighStartTicks, pwmHighEndTicks, pwmHighVal, pwmLowVal, flag
    if GPIO.input(SENSOR_DATA_PIN):
        pwmHighStartTicks = time.time() * 1000000  # Przechowujemy czas w mikrosekundach
        if flag == 2:
            flag = 4
            if pwmHighStartTicks > pwmHighEndTicks:
                pwmLowVal = pwmHighStartTicks - pwmHighEndTicks
        else:
            flag = 1
    else:
        pwmHighEndTicks = time.time() * 1000000
        if flag == 1:
            flag = 2
            if pwmHighEndTicks > pwmHighStartTicks:
                pwmHighVal = pwmHighEndTicks - pwmHighStartTicks


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


# Dodanie obsługi przerwania na danym kanale
GPIO.setwarnings(False)
GPIO.add_event_detect(SENSOR_DATA_PIN, GPIO.BOTH, callback=interruptChange)

try:
    while True:
        time.sleep(1)
        if flag == 4:
            flag = 1
            pwmHighVal_ms = (pwmHighVal * 1000.0) / (pwmLowVal + pwmHighVal)

            if pwmHighVal_ms < 0.01:
                print("Fault")
            elif pwmHighVal_ms < 80.00:
                print("preheating")
            elif pwmHighVal_ms < 998.00:
                concentration = (pwmHighVal_ms - 2) * 5
                print(f"pwmHighVal_ms: {pwmHighVal_ms}ms")
                print(f"{concentration} ppm")
            else:
                print("Beyond the maximum range : 398~4980ppm")
            print()

        print(read_dht_values(17))

except KeyboardInterrupt:
    print("Przerwano przez użytkownika.")

finally:
    GPIO.cleanup()
