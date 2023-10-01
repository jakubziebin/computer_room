import requests
import json

API_KEY = "0f0110a503e17bdf9c9c074b5c4b6e08"

LOCATION = "Gliwice,PL"

url = f"http://api.openweathermap.org/data/2.5/weather?q={LOCATION}&appid={API_KEY}"

response = requests.get(url)

data = json.loads(response.text)

temperature_k = data["main"]["temp"]
humidity = data["main"]["humidity"]
wind_speed = data["wind"]["speed"]
pressure = data["main"]["pressure"]
temperature_c = round(temperature_k - 273.15, 2)
weather_main = data["weather"][0]["main"]

print(f"{temperature_c}")
print(f"{humidity}")
print(f"{wind_speed}")
print(f"{pressure}")
print(f"{weather_main}")
