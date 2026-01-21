//
//  BackgroundAudioQuickStart.swift
//  Moonly - Quick Start Guide
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI
import AVFoundation

// MARK: - Quick Start: Minimal Example

/// Minimal example showing TTS + Background Audio together
struct MinimalBackgroundAudioExample: View {
    @StateObject private var audio = SimpleAudioManager()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Bedtime Story Player")
                .font(.title)
            
            // Play Story button
            Button("Play Story with Rain") {
                audio.playStoryWithBackground(
                    text: "Once upon a time, in a peaceful forest...",
                    backgroundSound: "rain"
                )
            }
            .buttonStyle(.borderedProminent)
            
            // Stop button
            Button("Stop All") {
                audio.stopAll()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Simple Audio Manager (All-in-One)

@MainActor
class SimpleAudioManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    private let synthesizer = AVSpeechSynthesizer()
    private var backgroundPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    // STEP 1: Configure Audio Session
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,           // Enables background playback
                mode: .spokenAudio,  // Optimized for speech
                options: [.mixWithOthers] // Allows both TTS + background audio
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Audio session error: \(error)")
        }
    }
    
    // STEP 2: Play TTS + Background Audio Together
    func playStoryWithBackground(text: String, backgroundSound: String) {
        // Start background audio first
        startBackgroundAudio(soundName: backgroundSound)
        
        // Then start speaking
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.40           // Slow, calm pace
        utterance.volume = 0.85         // Speech louder than background
        utterance.pitchMultiplier = 0.95
        
        synthesizer.speak(utterance)
    }
    
    // STEP 3: Background Audio Setup
    private func startBackgroundAudio(soundName: String) {
        // Stop existing background if playing
        backgroundPlayer?.stop()
        
        // Load audio file
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("❌ Could not find \(soundName).mp3")
            return
        }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1  // Loop forever
            backgroundPlayer?.volume = 0.30       // Keep it subtle
            backgroundPlayer?.play()
            print("✅ Playing background: \(soundName)")
        } catch {
            print("❌ Error loading audio: \(error)")
        }
    }
    
    // STEP 4: Stop Everything
    func stopAll() {
        synthesizer.stopSpeaking(at: .immediate)
        backgroundPlayer?.stop()
    }
    
    // Optional: Delegate methods for monitoring
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("🗣️ Started speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("✅ Finished speaking")
    }
}

// MARK: - Important Configuration Summary

/*
 
 🎯 THREE ESSENTIAL REQUIREMENTS:
 
 1️⃣ AUDIO SESSION CONFIGURATION (Most Important!)
    ────────────────────────────────────────────
    
    try AVAudioSession.sharedInstance().setCategory(
        .playback,              // ← Enables background playback
        mode: .spokenAudio,     // ← Optimized for speech
        options: [.mixWithOthers] // ← Allows TTS + background to play together
    )
 
 
 2️⃣ XCODE BACKGROUND MODES (Required for screen lock/background)
    ─────────────────────────────────────────────────────────────
    
    In Xcode:
    - Select your target
    - Go to "Signing & Capabilities"
    - Add "Background Modes" capability
    - Check "Audio, AirPlay, and Picture in Picture"
 
 
 3️⃣ VOLUME BALANCE (For good user experience)
    ───────────────────────────────────────────
    
    Speech (TTS):     0.85 (clear and primary)
    Background Audio: 0.30 (subtle atmosphere)
    
    utterance.volume = 0.85
    audioPlayer.volume = 0.30
 
 
 ──────────────────────────────────────────────────────────────
 
 📱 WHAT YOU GET:
 
 ✅ TTS voice plays clearly
 ✅ Background sound plays simultaneously
 ✅ Both continue when screen locks
 ✅ Both continue when app goes to background
 ✅ Independent volume control
 ✅ No interference between audio sources
 
 ──────────────────────────────────────────────────────────────
 
 🧪 TESTING:
 
 1. Run on PHYSICAL DEVICE (Simulator doesn't support background audio)
 2. Lock the screen → Audio should continue
 3. Press home button → Audio should continue
 4. Adjust volume → Both should respond appropriately
 
 ──────────────────────────────────────────────────────────────
 
 📁 AUDIO FILES:
 
 Add to your Xcode project:
 - rain.mp3
 - ocean.mp3
 - lullaby.mp3
 - night.mp3
 
 Recommended settings:
 - Format: MP3 or M4A
 - Bitrate: 128-192 kbps
 - Loop: 1-3 minutes for seamless looping
 
 ──────────────────────────────────────────────────────────────
 
 */

// MARK: - Alternative: Using Published Properties

@MainActor
class ReactiveAudioManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    // Published state for SwiftUI
    @Published var isSpeaking = false
    @Published var isBackgroundPlaying = false
    @Published var backgroundVolume: Float = 0.30
    
    private let synthesizer = AVSpeechSynthesizer()
    private var backgroundPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .spokenAudio,
            options: [.mixWithOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func playStory(text: String, withBackground soundName: String) {
        startBackgroundAudio(soundName: soundName)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.40
        utterance.volume = 0.85
        utterance.pitchMultiplier = 0.95
        
        synthesizer.speak(utterance)
    }
    
    func startBackgroundAudio(soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            return
        }
        
        backgroundPlayer = try? AVAudioPlayer(contentsOf: url)
        backgroundPlayer?.numberOfLoops = -1
        backgroundPlayer?.volume = backgroundVolume
        backgroundPlayer?.play()
        
        isBackgroundPlaying = true
    }
    
    func stopBackgroundAudio() {
        backgroundPlayer?.stop()
        isBackgroundPlaying = false
    }
    
    func setBackgroundVolume(_ volume: Float) {
        backgroundVolume = max(0.0, min(1.0, volume))
        backgroundPlayer?.volume = backgroundVolume
    }
    
    func stopAll() {
        synthesizer.stopSpeaking(at: .immediate)
        stopBackgroundAudio()
    }
    
    // Delegate methods
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}

// MARK: - Usage with Published Properties

struct ReactiveBackgroundAudioExample: View {
    @StateObject private var audio = ReactiveAudioManager()
    
    var body: some View {
        VStack(spacing: 30) {
            // Status indicators
            HStack(spacing: 20) {
                StatusBadge(
                    title: "Speaking",
                    isActive: audio.isSpeaking,
                    icon: "waveform"
                )
                
                StatusBadge(
                    title: "Background",
                    isActive: audio.isBackgroundPlaying,
                    icon: "music.note"
                )
            }
            
            // Background volume control
            VStack {
                Text("Background Volume")
                    .font(.caption)
                
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(
                        value: Binding(
                            get: { audio.backgroundVolume },
                            set: { audio.setBackgroundVolume($0) }
                        ),
                        in: 0...1
                    )
                    Image(systemName: "speaker.wave.3.fill")
                }
            }
            .padding()
            
            // Controls
            Button("Play Story with Ocean") {
                audio.playStory(
                    text: "The ocean waves gently rolled to shore...",
                    withBackground: "ocean"
                )
            }
            .buttonStyle(.borderedProminent)
            
            Button("Stop All") {
                audio.stopAll()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct StatusBadge: View {
    let title: String
    let isActive: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isActive ? .green : .gray)
            
            Text(title)
                .font(.caption)
                .foregroundColor(isActive ? .primary : .secondary)
            
            Circle()
                .fill(isActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

// MARK: - Previews

#Preview("Minimal Example") {
    MinimalBackgroundAudioExample()
}

#Preview("Reactive Example") {
    ReactiveBackgroundAudioExample()
}

// MARK: - FAQ

/*
 
 ❓ Q: Can I play background audio and TTS at the same time?
 ✅ A: Yes! Use AVAudioPlayer for background and AVSpeechSynthesizer for speech.
 
 ❓ Q: Why does audio stop when I lock the screen?
 ✅ A: You need to:
     1. Set audio session category to .playback
     2. Add "Background Modes" capability in Xcode
 
 ❓ Q: How do I control volumes separately?
 ✅ A: AVAudioPlayer has its own .volume property (0-1)
     AVSpeechUtterance also has .volume property (0-1)
 
 ❓ Q: What's the recommended volume balance?
 ✅ A: Speech: 0.85, Background: 0.20-0.40
 
 ❓ Q: Can I fade in/out the background audio?
 ✅ A: Yes! See BackgroundAudioManager.fadeVolume() in the main implementation
 
 ❓ Q: Does this work in the simulator?
 ✅ A: Speech works, but background audio continuation doesn't. Test on device!
 
 ❓ Q: What audio format should I use?
 ✅ A: MP3 or M4A, 128-192 kbps, 44.1 kHz sample rate
 
 ❓ Q: How do I make audio loop seamlessly?
 ✅ A: Set audioPlayer.numberOfLoops = -1 for infinite loop
 
 ❓ Q: Will this drain battery?
 ✅ A: Audio playback is efficient. For bedtime use, consider stopping after
     story ends or implementing a sleep timer.
 
 */
