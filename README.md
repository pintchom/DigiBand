# Adaptive Music Band Tool

A collaborative music system designed for special needs education, enabling students to participate in group music-making through accessible switch interfaces.

## System Overview

The system consists of:
- iPad app (Host)
- ESP32-S3 N8R8 (Main Controller)
- 4 x Raspberry Pi Pico W devices (Instrument Controllers)
- Adaptive switches for student input

### Communication Flow
1. iPad connects to main controller via Bluetooth
2. Main controller hosts WiFi network for instrument controllers
3. Instrument controllers read switch inputs and send signals to main controller
4. Main controller aggregates signals and sends to iPad
5. iPad plays corresponding instrument sounds

## Features
- Real-time music triggering
- Multiple simultaneous instruments
- Configurable sound assignments
- Wireless connectivity
- Simple, accessible interface

## Hardware Requirements
- iPad (iOS 17+)
- Circuit Playground Bluefruit
- Raspberry Pi Pico W (1 per instrument)
- Adaptive switches
- USB power supply for controllers

## Software Components
- iOS app (Swift)
- CircuitPython firmware for ESP32-S3 N8R8
- CircuitPython firmware for Pico Ws
- WebSocket server for device communication

  Instructable: ![link](https://www.instructables.com/DIGIBAND-Accessibility-Drum-Machine-Bluetooth-Rece/)

![image](https://github.com/user-attachments/assets/ec8033e4-889e-4f45-bb79-28f6afb1d00a)
