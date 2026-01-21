//
//  BackgroundAudioManager.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import AVFoundation
import Combine

/// Manages background ambient sounds for bedtime stories
/// Handles audio session configuration to play alongside speech synthesis
@MainActor
class BackgroundAudioManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isPlaying = false
    @Published var currentSound: AmbientSound?
    @Published var volume: Float = 0.3 // Background should be subtle (0.0 - 1.0)
    
    // MARK: - Private Properties
    
    private var audioPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    
    // MARK: - Ambient Sound Types
    
    enum AmbientSound: String, CaseIterable, Identifiable {
        case rain = "Rain"
        case ocean = "Ocean Waves"
        case nightAmbience = "Night Ambience"
        case lullaby = "Soft Lullaby"
        case whitenoise = "White Noise"
        case forestNight = "Forest Night"
        
        var id: String { rawValue }
        
        var filename: String {
            switch self {
            case .rain: return "ambient_rain"
            case .ocean: return "ambient_ocean"
            case .nightAmbience: return "ambient_night"
            case .lullaby: return "ambient_lullaby"
            case .whitenoise: return "ambient_whitenoise"
            case .forestNight: return "ambient_forest"
            }
        }
        
        var icon: String {
            switch self {
            case .rain: return "cloud.rain.fill"
            case .ocean: return "water.waves"
            case .nightAmbience: return "moon.stars.fill"
            case .lullaby: return "music.note"
            case .whitenoise: return "waveform"
            case .forestNight: return "tree.fill"
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        configureAudioSession()
    }
    
    // MARK: - Audio Session Configuration
    
    /// Configure audio session to allow mixing with speech synthesis
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // KEY: Use .playback with .mixWithOthers to allow speech + background audio
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio, // Optimized for speech content
                options: [.mixWithOthers, .duckOthers] // Mix with speech, duck when needed
            )
            
            try audioSession.setActive(true)
            
            print("✅ Background audio session configured")
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Playback Control
    
    /// Start playing background sound
    func play(sound: AmbientSound, fadeIn: Bool = true) {
        // Stop current sound if playing
        if isPlaying {
            stop(fadeOut: false)
        }
        
        // Load audio file
        guard let url = Bundle.main.url(forResource: sound.filename, withExtension: "mp3") else {
            print("❌ Could not find audio file: \(sound.filename).mp3")
            return
        }
        
        do {
            // Create audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = fadeIn ? 0.0 : volume
            
            // Prepare and play
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentSound = sound
            isPlaying = true
            
            // Fade in for smooth start
            if fadeIn {
                fadeVolume(to: volume, duration: 2.0)
            }
            
            print("✅ Started playing: \(sound.rawValue)")
        } catch {
            print("❌ Failed to initialize audio player: \(error)")
        }
    }
    
    /// Stop playing background sound
    func stop(fadeOut: Bool = true) {
        guard isPlaying else { return }
        
        if fadeOut {
            fadeVolume(to: 0.0, duration: 1.5) { [weak self] in
                self?.audioPlayer?.stop()
                self?.audioPlayer = nil
                self?.isPlaying = false
                self?.currentSound = nil
            }
        } else {
            audioPlayer?.stop()
            audioPlayer = nil
            isPlaying = false
            currentSound = nil
        }
    }
    
    /// Pause background sound (can be resumed)
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    /// Resume paused background sound
    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    // MARK: - Volume Control
    
    /// Set background volume (0.0 - 1.0)
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioPlayer?.volume = volume
    }
    
    /// Fade volume smoothly over duration
    private func fadeVolume(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let player = audioPlayer else {
            completion?()
            return
        }
        
        fadeTimer?.invalidate()
        
        let startVolume = player.volume
        let steps = 50
        let stepDuration = duration / Double(steps)
        let volumeStep = (targetVolume - startVolume) / Float(steps)
        
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            
            // Timer runs on main run loop, so we can safely assume main actor isolation
            MainActor.assumeIsolated {
                currentStep += 1
                
                let newVolume = startVolume + (volumeStep * Float(currentStep))
                self.audioPlayer?.volume = newVolume
                
                if currentStep >= steps {
                    timer.invalidate()
                    self.audioPlayer?.volume = targetVolume
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        fadeTimer?.invalidate()
        audioPlayer?.stop()
    }
}

// MARK: - Background Audio Continuation

extension BackgroundAudioManager {
    /// Enable background audio to continue when app is backgrounded or screen is locked
    /// Call this from your App struct or main view
    static func enableBackgroundAudio() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.mixWithOthers]
            )
            try audioSession.setActive(true)
            
            print("✅ Background audio enabled for app backgrounding")
        } catch {
            print("❌ Failed to enable background audio: \(error)")
        }
    }
}
