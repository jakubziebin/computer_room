import RPi.GPIO as GPIO

import time

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


# Dodanie obsługi przerwania na danym kanale
GPIO.add_event_detect(SENSOR_DATA_PIN, GPIO.BOTH, callback=interruptChange)

try:
    print("Oczekiwanie na przerwania...")
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
                print("pwmHighVal_ms: {}ms".format(pwmHighVal_ms))
                print("{} ppm".format(concentration))
            else:
                print("Beyond the maximum range : 398~4980ppm")
            print()

except KeyboardInterrupt:
    print("Przerwano przez użytkownika.")

finally:
    GPIO.cleanup()
