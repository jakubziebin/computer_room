from __future__ import annotations

from typing import Final
import asyncio

from textual import on, work
from textual.containers import Horizontal
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Button
from textual.reactive import var

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
from DFRobot_SCD4X import *
import RPi.GPIO as GPIO


async def open_window(openning_time: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is connected to the motor driver.d
    """
    OPEN_WINDOW_PIN: Final[int] = 13
    
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    GPIO.setup(OPEN_WINDOW_PIN, GPIO.OUT)
    GPIO.output(OPEN_WINDOW_PIN, GPIO.LOW)
    await asyncio.sleep(openning_time)
    GPIO.output(OPEN_WINDOW_PIN, GPIO.HIGH)

async def close_window(closing_time: int) -> None:
    """
    Parameters
    -------------
    pin: the GPIO pin number that is responsible for closing the window.
    """
    CLOSE_WINDOW_PIN: Final[int] = 16
    
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)

    GPIO.setup(CLOSE_WINDOW_PIN, GPIO.OUT)
    GPIO.output(CLOSE_WINDOW_PIN, GPIO.LOW)
    await asyncio.sleep(closing_time)
    GPIO.output(CLOSE_WINDOW_PIN, GPIO.HIGH)


class ComputerRoomApp(App):
    DEFAULT_CSS = """
    Button {
        height: 12;
        width: 20;
        margin-left: 2;
        margin-right: 2;
    }

    Horizontal {
        align: center middle;
        width: 1fr;
    }
    """

    window_position: int = var(0)
    auto_mode: bool = var(False)
    
        
    def compose(self) -> ComposeResult:
        yield Header()
        with Horizontal(id="mode-choose-container"):
            yield Button("Close", id="mode-0")
            yield Button("Open", id="mode-1")
        yield Button("Change mode", id="change-mode")
        yield Footer()
    
    def on_mount(self) -> None:
        self.__auto_mode_interval = self.set_interval(120, self.auto_mode_script)
        self.__auto_mode_interval.pause()
        
    @on(Button.Pressed, "#mode-0")
    async def close_window(self) -> None:
        if self.window_position == 0:
            return
        
        if self.auto_mode:
            return
            
        self.window_position = 0
        await close_window(9)

    @on(Button.Pressed, "#mode-1")
    async def open_window(self) -> None:
        if self.window_position == 1:
            return
            
        if self.auto_mode:
            return
            
        self.window_position = 1
        await open_window(9)
    
    @on(Button.Pressed, "#change-mode")
    async def change_mode(self) -> None:
        if self.window_position == 1:
            await close_window(9)
            self.window_position = 0
            
        self.auto_mode = not self.auto_mode
        
        if self.auto_mode:
            self.__auto_mode_interval.resume()
            return
        self.__auto_mode_interval.pause()
    
    @work(name="our app worker")
    async def auto_mode_script(self) -> None:
        self.notify("Calculationg auto mode ...")
        co2, temp, hum = await self.read_value_from_sensor()
        self.notify(f"{co2} ppm {temp} °C {hum} %")
        if co2 > 1000 and self.window_position == 0:
            self.notify("openning window...")
            self.window_position = 1
            await open_window(9)
    
    async def read_value_from_sensor(self) -> float:

        sensor = DFRobot_SCD4X(i2c_addr = SCD4X_I2C_ADDR, bus = 1)

        while (not await sensor.begin):
            await asyncio.sleep(3)
        

        await sensor.enable_period_measure(SCD4X_STOP_PERIODIC_MEASURE)
        if(0 != await sensor.perform_self_test):
            await sensor.set_sleep_mode(SCD4X_WAKE_UP)
        

        average_CO2ppm = 0
        average_temperature = 0
        average_humidity = 0
        for i in range(0, 6):
            await sensor.measure_single_shot(SCD4X_MEASURE_SINGLE_SHOT)
            while(not sensor.get_data_ready_status):
                await asyncio.sleep(0.1)

            CO2ppm, temp, humidity = sensor.read_measurement
            if 0 != i:   # Discard the first set of data, because the chip datasheet indicates they are invalid

                average_CO2ppm += CO2ppm
                average_temperature += temp
                average_humidity += humidity
        return average_CO2ppm / 5, average_temperature / 5, average_humidity / 5
        
try:
    app = ComputerRoomApp()
    asyncio.run(app.run_async())
except KeyboardInterrupt:
    GPIO.cleanup()
