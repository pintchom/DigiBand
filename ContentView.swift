//
//  ContentView.swift
//  DigiBand
//
//  Created by Max Pintchouk on 11/18/24.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var audioPlayer: AVAudioPlayer!
    var body: some View {
        VStack {
            Text(bluetoothManager.isConnected ? "Connected to CPB" : "Searching for CPB...")
                .padding()
            
            if !bluetoothManager.lastMessage.isEmpty {
                if bluetoothManager.lastMessage == "A" {
                    Text("Last message: \(bluetoothManager.lastMessage)")
                        .padding()
                        .onAppear {
                            if bluetoothManager.lastMessage == "A" {
                                playSound(soundName: "alright")
                            }
                        }
                } else {
                    Text("Last message: \(bluetoothManager.lastMessage)")
                        .padding()
                }
            }
        }
    }
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("Could not read file named: \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("ERROR: \(error.localizedDescription) creating audio player")
        }
    }
    
}

#Preview {
    ContentView()
}
