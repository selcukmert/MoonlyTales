//
//  TTSManagerUsageExample.swift
//  Moonly - Bedtime Story TTS Usage Example
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI
import AVFoundation

// MARK: - Usage Example

/// This demonstrates how to use the SpeechManager in your SwiftUI views
struct BedtimeStoryPlayerExample: View {
    @StateObject private var ttsManager = SpeechManager()
    @Environment(\.dismiss) private var dismiss
    
    let storyText = """
    Once upon a time, in a magical forest, there lived a wise old owl. 
    Every night, the owl would tell stories to the young animals. 
    The stories were filled with adventure and wonder. 
    All the animals loved listening to the owl's gentle voice. 
    And when the stories ended, they would all fall asleep peacefully.
    """
    
    let language: AppLanguage = .english
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.08, green: 0.1, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Story content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bedtime Story")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Text(storyText)
                            .font(.system(size: 18, design: .serif))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(10)
                    }
                    .padding(24)
                }
                
                Spacer()
                
                // Enhanced Audio Player
                EnhancedAudioPlayer(
                    speechManager: ttsManager,
                    onPlay: {
                        ttsManager.speak(text: storyText, language: language)
                    },
                    onStop: {
                        ttsManager.stop()
                    }
                )
            }
        }
        .onDisappear {
            ttsManager.stop()
        }
    }
}

// MARK: - Enhanced Audio Player Component

struct EnhancedAudioPlayer: View {
    @ObservedObject var speechManager: SpeechManager
    let onPlay: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress indicator
            VStack(spacing: 8) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
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
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    // Sentence indicator
                    if speechManager.isPlaying {
                        Text("Sentence \(speechManager.currentSentenceIndex + 1)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text(timeString(from: speechManager.totalTime))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 24)
            
            // Control buttons
            HStack(spacing: 24) {
                // Stop button
                Button(action: onStop) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .disabled(!speechManager.isPlaying)
                .opacity(speechManager.isPlaying ? 1.0 : 0.5)
                
                // Play/Pause button (main control)
                Button(action: onPlay) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: speechManager.isPlaying && !speechManager.isPaused ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .offset(x: speechManager.isPlaying && !speechManager.isPaused ? 0 : 3)
                    }
                }
                
                // Status indicator
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    if speechManager.isPaused {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    } else if speechManager.isPlaying {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.green.opacity(0.3), lineWidth: 4)
                                    .scaleEffect(speechManager.isPlaying ? 1.5 : 1.0)
                                    .opacity(speechManager.isPlaying ? 0 : 1)
                                    .animation(
                                        .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                                        value: speechManager.isPlaying
                                    )
                            )
                    } else {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.08, green: 0.1, blue: 0.12).opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 20, y: -10)
        )
        .padding(.horizontal, 16)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Key Features Demonstrated

/*
 ✅ FEATURES INCLUDED:
 
 1. **Sentence-by-Sentence Reading**
    - Text is automatically split into sentences
    - Each sentence is spoken separately with natural pauses
 
 2. **Natural Pauses**
    - preUtteranceDelay: 0.3s (first sentence) or 0.5s (subsequent)
    - postUtteranceDelay: 0.6s between sentences
 
 3. **Optimized Speech Rate**
    - Turkish: 0.35 (very calm)
    - English: 0.40 (calm and clear)
 
 4. **Full Playback Controls**
    - Play: Starts reading
    - Pause: Pauses at current word (tap again to resume)
    - Resume: Continues from where it paused
    - Stop: Completely stops and resets
 
 5. **Progress Tracking**
    - currentTime: Updates every 0.1 seconds
    - totalTime: Calculated based on word count + pauses
    - currentSentenceIndex: Shows which sentence is being read
 
 6. **SwiftUI Integration**
    - ObservableObject with @Published properties
    - Fully reactive UI updates
    - Easy binding to SwiftUI views
 
 7. **Bedtime-Optimized Settings**
    - Lower pitch (0.95) for calming effect
    - Softer volume (0.85) for nighttime
    - Slow, steady pace for relaxation
 
 8. **Automatic Sentence Management**
    - Regex-based sentence splitting
    - Handles multiple punctuation marks (. ! ?)
    - Automatically moves to next sentence
    - Gracefully handles completion
 
 9. **Thread Safety**
    - All delegate callbacks dispatched to main queue
    - Proper timer management
    - Safe state updates
 
 10. **Memory Management**
     - Weak self in closures
     - Proper cleanup on stop/finish
     - Timer invalidation
 
 USAGE IN YOUR APP:
 
 1. Create a SpeechManager instance:
    @StateObject private var speechManager = SpeechManager()
 
 2. Call speak() with your story text:
    speechManager.speak(text: storyText, language: .english)
 
 3. Bind to UI:
    - $speechManager.isPlaying
    - $speechManager.currentTime
    - speechManager.totalTime
 
 4. Handle controls:
    - Play/Pause: Call speak() again (toggles pause)
    - Stop: Call speechManager.stop()
 
 5. Cleanup:
    .onDisappear { speechManager.stop() }
 */

// MARK: - Preview
#Preview {
    NavigationStack {
        BedtimeStoryPlayerExample()
    }
}
