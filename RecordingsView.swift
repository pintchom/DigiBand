import SwiftUI
import SwiftData
import AVFAudio
import FirebaseStorage

struct RecordingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recordings: [Recording]
    @State private var players: [Int: AVAudioPlayer] = [:]
    @State private var isPlaying = false
    @State private var currentRecording: Recording?
    @State private var playbackTimer: Timer?
    @State private var showingRenameAlert = false
    @State private var newRecordingName = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordings) { recording in
                    VStack(alignment: .leading) {
                        Text(recording.name)
                            .font(.headline)
                        Text("Created \(recording.createdAt.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recording.actions.count) actions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button(isPlaying && currentRecording == recording ? "Stop" : "Play") {
                                if isPlaying && currentRecording == recording {
                                    stopPlayback()
                                } else {
                                    startPlayback(recording)
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Rename") {
                                currentRecording = recording
                                showingRenameAlert = true
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Delete") {
                                modelContext.delete(recording)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("Recordings")
            .alert("Rename Recording", isPresented: $showingRenameAlert) {
                TextField("Recording Name", text: $newRecordingName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if let recording = currentRecording {
                        recording.name = newRecordingName
                    }
                }
            }
        }
    }
    
    private func startPlayback(_ recording: Recording) {
        stopPlayback()
        
        currentRecording = recording
        isPlaying = true
        
        let sortedActions = recording.actions.sorted { $0.timestamp < $1.timestamp }
        guard let firstTimestamp = sortedActions.first?.timestamp else { return }
        
        let startTime = Date()
        var currentIndex = 0
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            guard currentIndex < sortedActions.count else {
                stopPlayback()
                return
            }
            
            let action = sortedActions[currentIndex]
            let originalDelay = action.timestamp.timeIntervalSince(firstTimestamp)
            let currentDelay = Date().timeIntervalSince(startTime)
            
            if currentDelay >= originalDelay {
                playStorageSound(recording: recording, buttonNumber: action.buttonNumber)
                currentIndex += 1
            }
        }
    }
    
    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        isPlaying = false
        currentRecording = nil
    }
    
    private func playStorageSound(recording: Recording, buttonNumber: Int) {
        guard let soundName = recording.instruments[buttonNumber] else { return }
        
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

#Preview {
    RecordingsView()
}
