import board, time, digitalio
import busio
from digitalio import DigitalInOut
from adafruit_esp32spi import adafruit_esp32spi
import adafruit_esp32spi.adafruit_esp32spi_socketpool as socket
import adafruit_requests
import os

# ESP32 pins
esp32_cs = DigitalInOut(board.CS1)
esp32_ready = DigitalInOut(board.ESP_BUSY)
esp32_reset = DigitalInOut(board.ESP_RESET)

# SPI connection
spi = busio.SPI(board.SCK1, board.MOSI1, board.MISO1)
esp = adafruit_esp32spi.ESP_SPIcontrol(spi, esp32_cs, esp32_ready, esp32_reset)

# Create a socket pool
pool = socket.SocketPool(esp)
requests = adafruit_requests.Session(pool, esp)

# Rest of your existing button setup
button_input = digitalio.DigitalInOut(board.D12)
button_input.switch_to_input(digitalio.Pull.UP)
button_pressed = False
last_state = button_input.value

HOST_URL = "http://10.20.73.111/"

def connect_to_wifi():
    max_attempts = 3
    attempt = 0

    while attempt < max_attempts:
        try:
            print(f"Connecting to WiFi (attempt {attempt + 1})...")
            esp.connect_AP(os.getenv("WIFI_SSID"), os.getenv("WIFI_PASSWORD"))
            print(f"Connected! IP: {esp.pretty_ip(esp.ip_address)}")
            return True
        except Exception as e:
            print(f"WiFi connection failed: {e}")
            attempt += 1
            time.sleep(2)
    return False

def send_signal():
    print("Requesting send-signal")
    try:
        response = requests.post(
            HOST_URL + "send-signal", 
            json={"device": 1}
        )
        print("Response status code:", response.status_code)
        print("Response text:", response.text)
        response.close()
        return response.text
    except Exception as e:
        print("Error making request:", str(e))
        return None

# After ESP initialization, before WiFi connection
mac = ["{:02x}".format(b) for b in esp.MAC_address]
print("MAC Address:", ":".join(mac))

# Initialize WiFi
if not esp.is_connected:
    connect_to_wifi()

# Main loop
while True:
    current_state = button_input.value
    if current_state != last_state:
        if not current_state:  # Button pressed
            print("Button pressed")
            send_signal()
        last_state = current_state
    time.sleep(0.1)