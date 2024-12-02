//
//  EditArrangementView.swift
//  DigiBand
//
//  Created by Max Pintchouk on 11/28/24.
//

import SwiftUI
import FirebaseStorage

struct EditArrangementView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var soundAssignments: [Int: String]
    @State private var soundFolders: [String: [String]] = [:]
    @State private var showingSoundSelector = false
    @State private var selectedButton: Int?
    @State private var isLoading = true
    @State private var isCancelled = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(1...4, id: \.self) { buttonNumber in
                    ButtonSectionView(
                        buttonNumber: buttonNumber,
                        soundAssignments: $soundAssignments,
                        onTapBrowse: {
                            if !isLoading {
                                selectedButton = buttonNumber
                                showingSoundSelector = true
                            }
                        }
                    )
                }
            }
            .navigationTitle("Edit Arrangement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSoundSelector) {
                NavigationView {
                    if let buttonNum = selectedButton {
                        SoundSelectorView(
                            soundFolders: soundFolders,
                            buttonNumber: buttonNum,
                            soundAssignments: $soundAssignments,
                            isPresented: $showingSoundSelector
                        )
                    }
                }
            }
        }
        .onAppear {
            // Initialize sound assignments if empty
            for i in 1...4 {
                if soundAssignments[i] == nil {
                    soundAssignments[i] = ""
                }
            }
        }
        .onDisappear {
            isCancelled = true
        }
        .task {
            // Reset cancelled state when task starts
            isCancelled = false
            if soundFolders.isEmpty {
                await loadSoundsFromFirebase()
            }
        }
    }
    
    private func loadSoundsFromFirebase() async {
        guard !isCancelled else { return }
        
        let storage = Storage.storage()
        let soundsRef = storage.reference().child("sounds")
        
        do {
            let result = try await soundsRef.listAll()
            var tempSoundFolders: [String: [String]] = [:]
            
            for folder in result.prefixes {
                guard !isCancelled else { return }
                
                do {
                    let folderContents = try await folder.listAll()
                    let sounds = folderContents.items.map { $0.name }
                    tempSoundFolders[folder.name] = sounds
                } catch {
                    print("Error listing sounds in \(folder.name): \(error.localizedDescription)")
                }
            }
            
            // Check if cancelled before updating UI
            guard !isCancelled else { return }
            
            await MainActor.run {
                guard !isCancelled else { return }
                self.soundFolders = tempSoundFolders
                self.isLoading = false
            }
        } catch {
            print("Error listing folders: \(error.localizedDescription)")
            if !isCancelled {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// Create a separate view for the button section
struct ButtonSectionView: View {
    let buttonNumber: Int
    @Binding var soundAssignments: [Int: String]
    let onTapBrowse: () -> Void
    
    var body: some View {
        Section("Button \(buttonNumber)") {
            VStack(alignment: .leading) {
                Text("Current sound: \(soundAssignments[buttonNumber]?.split(separator: "/").last?.replacingOccurrences(of: ".wav", with: "") ?? "None")")
                    .padding(.vertical, 4)
                
                Button("Browse Sounds", action: onTapBrowse)
                    .foregroundColor(.blue)
            }
        }
    }
}

// Create a separate view for the sound selector
struct SoundSelectorView: View {
    let soundFolders: [String: [String]]
    let buttonNumber: Int
    @Binding var soundAssignments: [Int: String]
    @Binding var isPresented: Bool
    
    var body: some View {
        List {
            ForEach(Array(soundFolders.keys).sorted(), id: \.self) { folder in
                FolderSection(
                    folder: folder,
                    sounds: soundFolders[folder] ?? [],
                    buttonNumber: buttonNumber,
                    soundAssignments: $soundAssignments,
                    isPresented: $isPresented
                )
            }
        }
        .navigationTitle("Select Sound")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") {
                    isPresented = false
                }
            }
        }
    }
}

// Create a separate view for each folder section
struct FolderSection: View {
    let folder: String
    let sounds: [String]
    let buttonNumber: Int
    @Binding var soundAssignments: [Int: String]
    @Binding var isPresented: Bool
    
    var body: some View {
        DisclosureGroup(folder) {
            ForEach(sounds, id: \.self) { sound in
                Button {
                    soundAssignments[buttonNumber] = "\(folder)/\(sound)"
                    isPresented = false
                } label: {
                    HStack {
                        Text(sound.replacingOccurrences(of: ".wav", with: ""))
                        Spacer()
                        if isCurrentlySelected(sound) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
    }
    
    private func isCurrentlySelected(_ sound: String) -> Bool {
        guard let currentAssignment = soundAssignments[buttonNumber] else {
            return false
        }
        return currentAssignment == "\(folder)/\(sound)"
    }
}

#Preview {
    EditArrangementView(soundAssignments: .constant([1: "taps/Tap (1).wav"]))
}
