//
//  ContentView.swift
//  DigiBand
//
//  Created by Max Pintchouk on 11/18/24.
//

import SwiftUI
import AVFAudio
import FirebaseStorage
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recordings: [Recording]
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var players: [Int: AVAudioPlayer] = [:]
    @State private var showingSoundBrowser = false
    @State private var showingEditArrangement = false
    @State private var isRecording = false
    @State private var recordedActions: [RecordedAction] = []
    @State private var soundAssignments = [
        1: "taps/Tap (1).wav",
        2: "taps/Tap (2).wav",
        3: "taps/Tap (3).wav",
        4: "taps/Tap (4).wav"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Circle()
                        .fill(bluetoothManager.isConnected ? .green : .red)
                        .frame(width: 36, height: 36)
                        .opacity(bluetoothManager.isConnected ? 1.0 : 0.6)
                        .animation(!bluetoothManager.isConnected ? Animation.easeInOut(duration: 1).repeatForever() : nil, value: bluetoothManager.isConnected)
                    Text(bluetoothManager.isConnected ? "Connected to Host Controller" : "Searching for Host Controller...")
                    Spacer()
                    NavigationLink("Recordings") {
                        RecordingsView()
                    }
                }
                .padding()
                .padding(.top, 36)
                Spacer()
                HStack {
                    Button {
                        playStorageSound(buttonNumber: 1)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 1))
                        }
                    } label: {
                        Text("A")
                            .font(.title)
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        playStorageSound(buttonNumber: 2)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 2))
                        }
                    } label: {
                        Text("B")
                            .font(.title)
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        playStorageSound(buttonNumber: 3)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 3))
                        }
                    } label: {
                        Text("C")
                            .font(.title)
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        playStorageSound(buttonNumber: 4)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 4))
                        }
                    } label: {
                        Text("D")
                            .font(.title)
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                }
                if !bluetoothManager.lastMessage.isEmpty {
                    Text("Last message: \(bluetoothManager.lastMessage)")
                        .padding()
                }
                
                HStack {
                    Button("Browse Sounds") {
                        showingSoundBrowser = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Edit Arrangement") {
                        showingEditArrangement = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button(isRecording ? "Stop Recording" : "Start Recording") {
                        if isRecording {
                            // Save recording to SwiftData
                            let recording = Recording(actions: recordedActions, instruments: soundAssignments)
                            modelContext.insert(recording)
                            recordedActions = []
                        }
                        isRecording.toggle()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(isRecording ? .red : .blue)
                }
                .padding()
                Spacer()
            }
            .onChange(of: bluetoothManager.messageReceived) { _ in
                switch bluetoothManager.lastMessage {
                    case "A":
                        playStorageSound(buttonNumber: 1)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 1))
                        }
                    case "B":
                        playStorageSound(buttonNumber: 2)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 2))
                        }
                    case "C":
                        playStorageSound(buttonNumber: 3)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 3))
                        }
                    case "D":
                        playStorageSound(buttonNumber: 4)
                        if isRecording {
                            recordedActions.append(RecordedAction(timestamp: Date(), buttonNumber: 4))
                        }
                    default:
                        break
                }
            }
            .fullScreenCover(isPresented: $showingSoundBrowser) {
                SoundBrowserView()
            }
            .fullScreenCover(isPresented: $showingEditArrangement) {
                EditArrangementView(soundAssignments: $soundAssignments)
            }
        }
    }
    
    func playStorageSound(buttonNumber: Int) {
        guard let soundName = soundAssignments[buttonNumber] else { return }
        
        let storage = Storage.storage()
        // Split the sound path into folder and file components
        let components = soundName.split(separator: "/")
        guard components.count == 2 else { return }
        
        let folderName = String(components[0])
        let fileName = String(components[1])
        let soundRef = storage.reference().child("sounds/\(folderName)/\(fileName)")
        
        soundRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading sound: \(error.localizedDescription)")
                return
            }
            
            guard let soundData = data else { return }
            
            do {
                players[buttonNumber]?.stop()
                players[buttonNumber] = try AVAudioPlayer(data: soundData)
                players[buttonNumber]?.play()
            } catch {
                print("ERROR: \(error.localizedDescription) creating audio player")
            }
        }
    }
}

extension NSDataAsset {
    static func allAssetNames(matching prefix: String = "") -> [String] {
        let assetNames = Bundle.main.paths(forResourcesOfType: "dataset", inDirectory: "Assets.xcassets")
            .compactMap { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
            .filter { $0.hasPrefix(prefix) }
        return assetNames.sorted()
    }
}

#Preview {
    ContentView()
}
