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
    @State private var players = []
    @State private var audioPlayer1: AVAudioPlayer!
    @State private var audioPlayer2: AVAudioPlayer!
    @State private var audioPlayer3: AVAudioPlayer!
    @State private var audioPlayer4: AVAudioPlayer!
    var body: some View {
        VStack {
            Text(bluetoothManager.isConnected ? "Connected to CPB" : "Searching for CPB...")
                .padding()
            HStack {
                Button {
                    playSound(soundName: "hat", audioPlayer: 1)
                } label: {
                    Text("1")
                }
                .buttonStyle(.borderedProminent)
                Button {
                    playSound(soundName: "tamborine", audioPlayer: 2)
                } label: {
                    Text("2")
                }
                .buttonStyle(.borderedProminent)
                Button {
                    playSound(soundName: "snare", audioPlayer: 3)
                } label: {
                    Text("3")
                }
                .buttonStyle(.borderedProminent)
                Button {
                    playSound(soundName: "synth", audioPlayer: 4)
                    playSound(soundName: "snare", audioPlayer: 3)
                } label: {
                    Text("4")
                }
                .buttonStyle(.borderedProminent)
                
            }
            if !bluetoothManager.lastMessage.isEmpty {
                if bluetoothManager.lastMessage == "A" {
                    Text("Last message: \(bluetoothManager.lastMessage)")
                        .padding()
                        .onAppear {
                            if bluetoothManager.lastMessage == "A" {
                                playSound(soundName: "tamborine", audioPlayer: 1)
                            }
                        }
                } else {
                    Text("Last message: \(bluetoothManager.lastMessage)")
                        .padding()
                }
            }
        }
    }
    func playSound(soundName: String, audioPlayer: Int) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("Could not read file named: \(soundName)")
            return
        }
        do {
            if audioPlayer == 1 {
                audioPlayer1 = try AVAudioPlayer(data: soundFile.data)
                audioPlayer1.play()
            } else if audioPlayer == 2 {
                audioPlayer2 = try AVAudioPlayer(data: soundFile.data)
                audioPlayer2.play()
            } else if audioPlayer == 3 {
                audioPlayer3 = try AVAudioPlayer(data: soundFile.data)
                audioPlayer3.play()
            } else if audioPlayer == 4 {
                audioPlayer4 = try AVAudioPlayer(data: soundFile.data)
                audioPlayer4.play()
            }
        } catch {
            print("ERROR: \(error.localizedDescription) creating audio player")
        }
    }
}

#Preview {
    ContentView()
}
