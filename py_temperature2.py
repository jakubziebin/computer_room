import adafruit_dht
from board import D4

DHT_SENSOR = adafruit_dht.DHT22(D4)

temperature = DHT_SENSOR.temperature

if temperature is not None:
    print("{0:0.1f}".format(temperature))
else:
    print("10000")
