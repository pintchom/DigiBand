//
//  SoundBrowserView.swift
//  DigiBand
//
//  Created by Max Pintchouk on 11/28/24.
//

import SwiftUI
import AVFAudio
import FirebaseStorage

struct SoundBrowserView: View {
    @State private var soundFolders: [String: [String]] = [:]
    @State private var expandedFolders: Set<String> = []
    @State private var currentPlayer: AVAudioPlayer?
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(Array(soundFolders.keys).sorted(), id: \.self) { folder in
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedFolders.contains(folder) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedFolders.insert(folder)
                                        } else {
                                            expandedFolders.remove(folder)
                                        }
                                    }
                                )
                            ) {
                                ForEach(soundFolders[folder] ?? [], id: \.self) { soundName in
                                    HStack {
                                        Text(soundName)
                                        Spacer()
                                        Button {
                                            playPreviewSound(folder: folder, name: soundName)
                                        } label: {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title2)
                                        }
                                    }
                                }
                            } label: {
                                Text(folder)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Sound Browser")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadSoundFolders()
        }
    }
    
    private func loadSoundFolders() {
        let storage = Storage.storage()
        let soundsRef = storage.reference().child("sounds")
        
        soundsRef.listAll { result, error in
            if let error = error {
                print("Error listing folders: \(error.localizedDescription)")
                return
            }
            
            guard let folders = result?.prefixes else { return }
            let group = DispatchGroup()
            
            for folder in folders {
                group.enter()
                folder.listAll { result, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("Error listing sounds in \(folder.name): \(error.localizedDescription)")
                        return
                    }
                    
                    let sounds = result?.items.map { $0.name } ?? []
                    DispatchQueue.main.async {
                        self.soundFolders[folder.name] = sounds
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.isLoading = false
            }
        }
    }
    
    private func playPreviewSound(folder: String, name: String) {
        let storage = Storage.storage()
        let soundRef = storage.reference().child("sounds/\(folder)/\(name)")
        
        soundRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading sound: \(error.localizedDescription)")
                return
            }
            
            guard let soundData = data else { return }
            
            do {
                currentPlayer?.stop()
                currentPlayer = try AVAudioPlayer(data: soundData)
                currentPlayer?.play()
            } catch {
                print("ERROR: \(error.localizedDescription) creating audio player")
            }
        }
    }
}

#Preview {
    SoundBrowserView()
}
