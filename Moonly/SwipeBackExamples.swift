//
//  SwipeBackExamples.swift
//  Moonly - Swipe Back Gesture Examples
//
//  Created by Mert Selçuk on 21.01.2026.
//

import SwiftUI
import Combine

// MARK: - Example 1: Basic Swipe Back

struct BasicSwipeBackExample: View {
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "hand.draw")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Swipe Right to Go Back")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Drag from anywhere on the screen")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "hand.point.right", text: "Swipe right to dismiss")
                InfoRow(icon: "arrow.left.circle", text: "Visual indicator appears")
                InfoRow(icon: "bolt", text: "Quick swipes trigger faster")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .swipeBack()  // ← Enable swipe back
    }
}

// MARK: - Example 2: Custom Threshold

struct CustomThresholdExample: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("🎯")
                .font(.system(size: 80))
            
            Text("Custom Threshold")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This requires swiping 200 points to dismiss")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            VStack(spacing: 16) {
                Text("Try swiping:")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    VStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Short Swipe")
                            .font(.caption)
                        Text("Won't dismiss")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Long Swipe")
                            .font(.caption)
                        Text("Will dismiss")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.largeTitle)
            }
        }
        .padding()
        .navigationBarHidden(true)
        .swipeBack(threshold: 200)  // ← Custom threshold
    }
}

// MARK: - Example 3: With Dismiss Callback

struct CallbackExample: View {
    @StateObject private var timer = DemoTimer()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("⏱️")
                .font(.system(size: 80))
            
            Text("Timer Demo")
                .font(.title)
                .fontWeight(.bold)
            
            // Timer display
            VStack(spacing: 8) {
                Text("Timer is running:")
                    .font(.headline)
                
                Text(timer.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            
            Text("Swipe back to stop the timer")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("The timer will automatically stop when you swipe back")
                        .font(.caption)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .swipeBack {
            // Stop timer before going back
            timer.stop()
            print("🛑 Timer stopped via swipe back")
        }
    }
}

// MARK: - Example 4: Simple Version (No Visual Indicator)

struct SimpleSwipeExample: View {
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "eye.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Simple Swipe")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No visual indicator, just the gesture")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "hand.point.right", text: "Swipe right to dismiss")
                InfoRow(icon: "eye.slash", text: "No visual feedback")
                InfoRow(icon: "gauge", text: "Lighter on performance")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .simpleSwipeBack()  // ← Simple version without indicator
    }
}

// MARK: - Example 5: Audio Player Integration

struct AudioPlayerSwipeExample: View {
    @StateObject private var audioManager = DemoAudioManager()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("🎵")
                .font(.system(size: 80))
            
            Text("Audio Player")
                .font(.title)
                .fontWeight(.bold)
            
            // Audio status
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(audioManager.isPlaying ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                    
                    Text(audioManager.isPlaying ? "Playing" : "Stopped")
                        .font(.headline)
                }
                
                if audioManager.isPlaying {
                    Text("Music will stop when you swipe back")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            
            // Play button
            Button(action: {
                audioManager.togglePlayback()
            }) {
                HStack {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    Text(audioManager.isPlaying ? "Pause" : "Play")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .swipeBack {
            // Stop audio playback when swiping back
            audioManager.stop()
            print("🛑 Audio stopped via swipe back")
        }
    }
}

// MARK: - Main Demo View

struct SwipeBackDemoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Basic Swipe Back") {
                        BasicSwipeBackExample()
                    }
                    
                    NavigationLink("Custom Threshold") {
                        CustomThresholdExample()
                    }
                    
                    NavigationLink("With Dismiss Callback") {
                        CallbackExample()
                    }
                    
                    NavigationLink("Simple Version (No Indicator)") {
                        SimpleSwipeExample()
                    }
                    
                    NavigationLink("Audio Player Integration") {
                        AudioPlayerSwipeExample()
                    }
                } header: {
                    Text("Swipe Back Examples")
                } footer: {
                    Text("All examples demonstrate swipe-right-to-dismiss gestures with various configurations")
                }
            }
            .navigationTitle("Swipe Back Demo")
        }
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Demo Helpers

@MainActor
class DemoTimer: ObservableObject {
    @Published var seconds: Int = 0
    private var timer: Timer?
    
    init() {
        start()
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.seconds += 1
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    var formattedTime: String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

@MainActor
class DemoAudioManager: ObservableObject {
    @Published var isPlaying = false
    
    func togglePlayback() {
        isPlaying.toggle()
    }
    
    func stop() {
        isPlaying = false
    }
}

// MARK: - Previews

#Preview("Demo List") {
    SwipeBackDemoView()
}

#Preview("Basic Example") {
    NavigationStack {
        BasicSwipeBackExample()
    }
}

#Preview("Custom Threshold") {
    NavigationStack {
        CustomThresholdExample()
    }
}

#Preview("With Callback") {
    NavigationStack {
        CallbackExample()
    }
}

// MARK: - Implementation Notes

/*
 
 📝 HOW TO USE SWIPE BACK IN YOUR VIEWS:
 ─────────────────────────────────────────
 
 1️⃣ BASIC USAGE (Recommended):
    
    struct MyView: View {
        var body: some View {
            VStack {
                Text("Content")
            }
            .navigationBarHidden(true)
            .swipeBack()  // ← Just add this!
        }
    }
 
 
 2️⃣ WITH CUSTOM THRESHOLD:
    
    .swipeBack(threshold: 150)  // Requires 150pt swipe
 
 
 3️⃣ WITH DISMISS CALLBACK:
    
    .swipeBack {
        // Clean up before dismissing
        audioManager.stop()
        timer.invalidate()
    }
 
 
 4️⃣ SIMPLE VERSION (No Visual Indicator):
    
    .simpleSwipeBack()  // Just gesture, no "Back" indicator
 
 
 ✨ FEATURES:
 ────────────
 
 ✅ Smooth spring animations
 ✅ Visual "Back" indicator (optional)
 ✅ Velocity detection
 ✅ Natural resistance curve
 ✅ Customizable threshold
 ✅ Dismiss callbacks
 ✅ Works with NavigationStack
 ✅ Reusable modifier
 
 
 🎯 BEST PRACTICES:
 ──────────────────
 
 • Use .swipeBack() for full-screen views
 • Use .simpleSwipeBack() for minimal UI
 • Set threshold based on content importance
 • Always clean up resources in callback
 • Hide navigation bar for better UX
 
 */
