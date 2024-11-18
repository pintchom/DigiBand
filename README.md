# Adaptive Music Band Tool

A collaborative music system designed for special needs education, enabling students to participate in group music-making through accessible switch interfaces.

## System Overview

The system consists of:
- iPad app (Host)
- Circuit Playground Bluefruit (Main Controller)
- Raspberry Pi Pico W devices (Instrument Controllers)
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
- iPad (iOS 14+)
- Circuit Playground Bluefruit
- Raspberry Pi Pico W (1 per instrument)
- Adaptive switches
- USB power supply for controllers

## Software Components
- iOS app (Swift)
- CircuitPython firmware for CPB
- CircuitPython firmware for Pico Ws
- WebSocket server for device communication

![image](https://github.com/user-attachments/assets/643c46a0-34ac-4bff-a791-02d989b889cb)
