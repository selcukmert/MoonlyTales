//
//  BedtimeStoryPlayerWithAmbience.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI
import AVFoundation

// MARK: - Complete Bedtime Story Player with Background Audio

/// Production-ready bedtime story player that combines TTS with ambient sounds
struct BedtimeStoryPlayerWithAmbience: View {
    let story: Story
    let language: AppLanguage
    
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var audioManager = BackgroundAudioManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showAmbientSoundPicker = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.07, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Story content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Story title
                        Text(story.title(for: language))
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        // Story metadata
                        HStack(spacing: 16) {
                            Label("\(story.readTime) min", systemImage: "clock")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Story content
                        Text(story.fullDescription(for: language))
                            .font(.system(size: 18, design: .serif))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(10)
                    }
                    .padding(24)
                    .padding(.bottom, 280) // Space for player
                }
                
                Spacer()
                
                // Player controls
                BedtimePlayerControls(
                    speechManager: speechManager,
                    audioManager: audioManager,
                    onShowAmbientPicker: { showAmbientSoundPicker = true }
                )
            }
        }
        .task {
            // Configure audio session for background playback
            BackgroundAudioManager.enableBackgroundAudio()
            
            // Prepare speech content
            await speechManager.prepareContent(text: story.fullDescription(for: language), language: language == .turkish ? .turkish : .english)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onDisappear {
            speechManager.stop()
            audioManager.stop(fadeOut: true)
        }
        .sheet(isPresented: $showAmbientSoundPicker) {
            AmbientSoundPickerView(audioManager: audioManager)
        }
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            print("📱 App entered background - audio continues playing")
            // Audio will continue playing due to our audio session configuration
        case .inactive:
            print("📱 App became inactive")
        case .active:
            print("📱 App became active")
        @unknown default:
            break
        }
    }
}

// MARK: - Player Controls

struct BedtimePlayerControls: View {
    @ObservedObject var speechManager: SpeechManager
    @ObservedObject var audioManager: BackgroundAudioManager
    let onShowAmbientPicker: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Ambient sound controls
            AmbientSoundControl(
                audioManager: audioManager,
                onShowPicker: onShowAmbientPicker
            )
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Speech progress
            SpeechProgressView(speechManager: speechManager)
            
            // Main controls
            HStack(spacing: 32) {
                // Stop button
                Button(action: {
                    speechManager.stop()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "stop.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .disabled(!speechManager.isPlaying)
                .opacity(speechManager.isPlaying ? 1.0 : 0.5)
                
                // Play/Pause button
                Button(action: {
                    speechManager.togglePlayPause()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: playPauseIcon)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .offset(x: speechManager.isPlaying && !speechManager.isPaused ? 0 : 3)
                    }
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .disabled(speechManager.isPreparingContent)
                
                // Settings placeholder (for future use)
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    PlaybackStatusIndicator(speechManager: speechManager)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.08, green: 0.1, blue: 0.12).opacity(0.98))
                .shadow(color: .black.opacity(0.4), radius: 30, y: -15)
        )
        .padding(.horizontal, 16)
    }
    
    private var playPauseIcon: String {
        if speechManager.isPreparingContent {
            return "hourglass"
        } else if speechManager.isPlaying && !speechManager.isPaused {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }
}

// MARK: - Ambient Sound Control

struct AmbientSoundControl: View {
    @ObservedObject var audioManager: BackgroundAudioManager
    let onShowPicker: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue.opacity(0.8))
                
                Text("Background Ambience")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                // Change sound button
                Button(action: onShowPicker) {
                    Text(audioManager.currentSound?.rawValue ?? "Select")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.15))
                        )
                }
            }
            
            // Volume control
            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                
                Slider(
                    value: Binding(
                        get: { audioManager.volume },
                        set: { audioManager.setVolume($0) }
                    ),
                    in: 0...1
                )
                .tint(.blue)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                
                // Play/Stop toggle
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.stop(fadeOut: true)
                    } else if let sound = audioManager.currentSound {
                        audioManager.play(sound: sound, fadeIn: true)
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(audioManager.isPlaying ? .orange : .green)
                }
                .disabled(audioManager.currentSound == nil)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Speech Progress View

struct SpeechProgressView: View {
    @ObservedObject var speechManager: SpeechManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 4)
                    
                    // Progress track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: speechManager.totalTime > 0
                                ? geometry.size.width * (speechManager.currentTime / speechManager.totalTime)
                                : 0,
                            height: 4
                        )
                        .animation(.linear(duration: 0.1), value: speechManager.currentTime)
                }
            }
            .frame(height: 4)
            
            // Time labels
            HStack {
                Text(timeString(from: speechManager.currentTime))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                if speechManager.isPlaying {
                    Text("Page \(speechManager.currentSentenceIndex + 1)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue.opacity(0.8))
                }
                
                Spacer()
                
                Text(timeString(from: speechManager.totalTime))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Playback Status Indicator

struct PlaybackStatusIndicator: View {
    @ObservedObject var speechManager: SpeechManager
    
    var body: some View {
        Group {
            if speechManager.isPaused {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
            } else if speechManager.isPlaying {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 4)
                        .frame(width: 12, height: 12)
                        .scaleEffect(speechManager.isPlaying ? 1.8 : 1.0)
                        .opacity(speechManager.isPlaying ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.2).repeatForever(autoreverses: false),
                            value: speechManager.isPlaying
                        )
                }
            } else {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - Ambient Sound Picker

struct AmbientSoundPickerView: View {
    @ObservedObject var audioManager: BackgroundAudioManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(BackgroundAudioManager.AmbientSound.allCases) { sound in
                        AmbientSoundRow(
                            sound: sound,
                            isSelected: audioManager.currentSound == sound,
                            isPlaying: audioManager.isPlaying && audioManager.currentSound == sound,
                            onTap: {
                                audioManager.play(sound: sound, fadeIn: true)
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color(red: 0.08, green: 0.1, blue: 0.12))
            .navigationTitle("Ambient Sounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AmbientSoundRow: View {
    let sound: BackgroundAudioManager.AmbientSound
    let isSelected: Bool
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: sound.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .blue : .white.opacity(0.7))
                }
                
                // Title
                Text(sound.rawValue)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Status
                if isPlaying {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Playing")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.green)
                    }
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Example Usage & Documentation

/*
 ✅ KEY FEATURES:
 
 1. **Simultaneous Audio Playback**
    - TTS voice plays through AVSpeechSynthesizer
    - Background ambience plays through AVAudioPlayer
    - Both can play at the same time without interference
 
 2. **Proper Audio Session Configuration**
    - Category: .playback (enables background playback)
    - Mode: .spokenAudio (optimized for speech)
    - Options: .mixWithOthers (allows both audio sources)
    
 3. **Independent Volume Control**
    - Speech volume: Controlled by AVSpeechSynthesizer (0.85 default)
    - Background volume: Controlled by AVAudioPlayer (0.3 default)
    - User can adjust background volume with slider
 
 4. **Background Audio Continuation**
    - Plays when app is backgrounded
    - Plays when screen is locked
    - Requires "Audio, AirPlay, and Picture in Picture" capability in Xcode
 
 5. **Smooth Transitions**
    - Fade in when starting (2 seconds)
    - Fade out when stopping (1.5 seconds)
    - Prevents jarring audio starts/stops
 
 6. **Multiple Ambient Sounds**
    - Rain, ocean waves, night ambience
    - Lullaby music, white noise, forest sounds
    - Easy to add more sounds
 
 7. **Production-Ready UI**
    - Ambient sound picker
    - Volume slider
    - Play/pause controls for background audio
    - Speech progress tracking
 
 ⚙️ XCODE SETUP REQUIRED:
 
 1. Enable Background Modes:
    - Open your target settings
    - Go to "Signing & Capabilities"
    - Add "Background Modes" capability
    - Check "Audio, AirPlay, and Picture in Picture"
 
 2. Add Audio Files:
    - Add .mp3 files to your project
    - Name them according to AmbientSound.filename
    - Example: ambient_rain.mp3, ambient_ocean.mp3
 
 3. Info.plist (optional but recommended):
    - Add "Privacy - Microphone Usage Description" if using speech recognition
 
 📱 HOW IT WORKS:
 
 1. Audio Session Configuration:
    - Both managers configure AVAudioSession.sharedInstance()
    - .mixWithOthers allows multiple audio sources
    - .duckOthers temporarily reduces other audio during speech
 
 2. Speech Synthesis:
    - SpeechManager uses AVSpeechSynthesizer
    - Speaks sentence by sentence
    - Updates progress every 0.1 seconds
 
 3. Background Audio:
    - BackgroundAudioManager uses AVAudioPlayer
    - Loops indefinitely (numberOfLoops = -1)
    - Separate volume control from speech
 
 4. Lifecycle Management:
    - Both continue in background (due to audio session config)
    - Properly cleanup on view disappear
    - Handle scene phase changes
 
 💡 TIPS FOR BEDTIME APPS:
 
 - Keep background volume low (0.2 - 0.4)
 - Use calming sounds (rain, ocean, gentle lullaby)
 - Slow speech rate (0.35 - 0.40)
 - Fade in/out for smooth experience
 - Consider auto-fade out after story ends
 
 🎯 USAGE:
 
 BedtimeStoryPlayerWithAmbience(story: myStory, language: .english)
 
 */

// MARK: - Preview

#Preview {
    if let story = Story.sampleStories.first {
        BedtimeStoryPlayerWithAmbience(story: story, language: .english)
    } else {
        Text("No sample stories available")
    }
}
