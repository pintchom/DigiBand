import board
import digitalio
from adafruit_ble import BLERadio
from adafruit_ble.advertising.standard import ProvideServicesAdvertisement
from adafruit_ble.services.nordic import UARTService

ble = BLERadio()
uart = UARTService()
advertisement = ProvideServicesAdvertisement(uart)

button_A = digitalio.DigitalInOut(board.BUTTON_A)
button_A.direction = digitalio.Direction.INPUT
button_A.pull = digitalio.Pull.DOWN

button_B = digitalio.DigitalInOut(board.BUTTON_B)
button_B.direction = digitalio.Direction.INPUT
button_B.pull = digitalio.Pull.DOWN

print("Starting BLE")

while True:
    ble.start_advertising(advertisement)
    print("Waiting for connection...")

    while not ble.connected:
        pass

    print("Connected!")

    while ble.connected:
        if button_A.value:
            uart.write("A".encode())
        if button_B.value:
            uart.write("B".encode())
