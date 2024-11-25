import board, time
import digitalio
from adafruit_ble import BLERadio
from adafruit_ble.advertising.standard import ProvideServicesAdvertisement
from adafruit_ble.services.nordic import UARTService
from adafruit_httpserver import Server, Request, Response
import os
import wifi
import socketpool
import supervisor
import adafruit_requests
import rtc
import circuitpython_schedule as schedule
import ssl

pool = None
requests = None
server = None

################################################################################################################
'''CONNECT TO WIFI'''

def connect_to_wifi():
    global pool
    global requests
    max_attempts = 3
    attempt = 0
    
    # Print WiFi credentials for debugging
    print(f"Attempting to connect with SSID: {os.getenv('WIFI_SSID')}")
    
    while attempt < max_attempts:
        try:
            print(f"Connecting to WiFi (attempt {attempt + 1})...")
            wifi.radio.connect(os.getenv("WIFI_SSID"), os.getenv("WIFI_PASSWORD"))
            print(f"Connected! IP: {wifi.radio.ipv4_address}")
            pool = socketpool.SocketPool(wifi.radio)
            # Test network connectivity
            requests = adafruit_requests.Session(pool)
            test_response = requests.get("http://google.com")
            test_response.close()
            print("Network connectivity confirmed")
            return True
        except Exception as e:
            print(f"WiFi connection failed: {str(e)}")
            attempt += 1
            time.sleep(2)
    return False

################################################################################################################
'''CONNECT TO BLE'''

ble = BLERadio()
uart = UARTService()
advertisement = ProvideServicesAdvertisement(uart)

print("Starting BLE")

################################################################################################################
'''SETUP SERVER'''

def setup_server():
    global server
    global alarm_times
    try:
        global pool  # Use the global pool instead of creating a new one
        if pool is None:
            print("Error: Socket pool not initialized")
            return None
            
        server = Server(pool, "/static", debug=True)
        print("Server object created successfully")

        @server.route("/")
        def base(request: Request):
            print("Received request to root")
            return Response(request, "Server is running!")

        @server.route("/send-signal", methods=["POST"])
        def stop_route(request: Request):
            print("Received request to send sound signal")
            try:
                # Parse JSON body from request
                body = request.json()
                device_id = body.get("device")
                print(device_id)
                if device_id is None:
                    return Response(request, "Missing device ID", status=400)
                
                if device_id == 1:
                    uart.write("A")
                    time.sleep(0.1)
                print("ALL GOOD")
                return Response(request, "Signal sent successfully")
                
            except ValueError:
                print("Invalid JSON body")
                return Response(request, "Invalid JSON body", status=400)

        print("Routes configured successfully")
        return server
    
    except Exception as e:
        print(f"Server setup failed: {str(e)}")
        return None

def run_server():
    print("Starting server initialization...")
    
    # Connect to WiFi
    if not connect_to_wifi():
        print("Failed to connect to WiFi after multiple attempts")
        time.sleep(5)  # Wait before reloading
        supervisor.reload()
        return

    server = setup_server()
    if not server:
        print("Failed to setup server")
        time.sleep(5)  # Wait before reloading
        supervisor.reload()
        return

    try:
        print("Starting server...")
        server.start(port=80)
        print(f"Server is running on http://{wifi.radio.ipv4_address}")
        print("Available routes:")
        print(f"  http://{wifi.radio.ipv4_address}/")
        print(f"  http://{wifi.radio.ipv4_address}/send-signal")

        while True:
            ble.start_advertising(advertisement)
            print("Waiting for connection...")
            while not ble.connected:
                pass

            print("Connected!")

            while ble.connected:
                try:
                    server.poll()
                    time.sleep(0.1)
                except Exception as e:
                    print(f"Error in server poll: {str(e)}")
                    time.sleep(1)  # Brief pause before continuing
                
    except Exception as e:
        print(f"Critical server error: {str(e)}")
        time.sleep(5)  # Wait before reloading
        supervisor.reload()

################################################################################################################
'''MAIN LOOP'''
run_server()


'''
AT BC: http://10.20.73.111/
'''
