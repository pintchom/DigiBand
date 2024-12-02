import board, time, digitalio
from adafruit_debouncer import Button
import wifi
import socketpool
import adafruit_requests
import os
import wifi
from adafruit_httpserver import Server, Request, Response
import supervisor
from adafruit_debouncer import Button

HOST_URL = "http://10.20.73.111/"

button_input = digitalio.DigitalInOut(board.GP15) # Wired to GP15
button_input.switch_to_input(digitalio.Pull.UP) # Note: Pull.UP for external buttons
button = Button(button_input) # NOTE: False for external buttons


def send_signal():
    print("Requesting send-signal")
    try:
        requests = adafruit_requests.Session(pool)
        response = requests.post(
            HOST_URL + "send-signal",
            json={"device": 2}  # Replace with actual device ID if needed
        )

        print("Response status code:", response.status_code)
        print("Response text:", response.text)

        response.close()
        return response.text

    except Exception as e:
        print("Error making request:", str(e))
        return None

pool = None
def connect_to_wifi():
    global pool
    max_attempts = 3
    attempt = 0

    while attempt < max_attempts:
        try:
            print(f"Connecting to WiFi (attempt {attempt + 1})...")
            wifi.radio.connect(os.getenv("WIFI_SSID"), os.getenv("WIFI_PASSWORD"))
            print(f"Connected! IP: {wifi.radio.ipv4_address}")
            pool = socketpool.SocketPool(wifi.radio)
            return True
        except Exception as e:
            print(f"WiFi connection failed: {e}")
            attempt += 1
            time.sleep(2)
    return False

connect_to_wifi()

while True:
    button.update()
    if button.pressed:
        print("Button pressed")
        send_signal()
        time.sleep(.1)