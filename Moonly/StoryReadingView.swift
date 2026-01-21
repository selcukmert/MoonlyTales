//
//  StoryReadingView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI
import AVFoundation

struct StoryReadingView: View {
    let story: Story
    @State private var currentChapterIndex = 0
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 252 // 4:12
    @State private var totalTime: TimeInterval = 750 // 12:30
    @Environment(\.dismiss) private var dismiss
    
    var currentChapter: Chapter {
        story.chapters[currentChapterIndex]
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.08, green: 0.1, blue: 0.12)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Chapter title
                    VStack(alignment: .center, spacing: 8) {
                        Text("CHAPTER \(romanNumeral(currentChapter.number))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(2)
                        
                        Text(currentChapter.title)
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                    .padding(.bottom, 20)
                    
                    // Story content
                    Text(currentChapter.content)
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(12)
                        .padding(.horizontal, 24)
                    
                    // Add more paragraphs for demonstration
                    Text("Stars began to blink into existence above the canopy, a thousand watching eyes in the velvet night. It was here, in this suspended silence, that time seemed to lose its grip. The rush of the city was a distant memory, replaced by the rhythmic breathing of the woods.")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(12)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    Spacer(minLength: 200)
                }
            }
            
            // Top bar
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
            }
            
            // Audio player at bottom
            VStack {
                Spacer()
                
                AudioPlayerView(
                    isPlaying: $isPlaying,
                    currentTime: $currentTime,
                    totalTime: totalTime
                )
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
    
    func romanNumeral(_ number: Int) -> String {
        let romanValues = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
        return number <= romanValues.count ? romanValues[number - 1] : "\(number)"
    }
}

struct AudioPlayerView: View {
    @Binding var isPlaying: Bool
    @Binding var currentTime: TimeInterval
    let totalTime: TimeInterval
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 4)
                        
                        // Progress track
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * (currentTime / totalTime), height: 4)
                    }
                }
                .frame(height: 4)
                
                // Time labels
                HStack {
                    Text(timeString(from: currentTime))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(timeString(from: totalTime))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 24)
            
            // Play button
            Button(action: {
                isPlaying.toggle()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .offset(x: isPlaying ? 0 : 2)
                }
            }
        }
        .padding(.vertical, 20)
        .background(
            Rectangle()
                .fill(Color(red: 0.08, green: 0.1, blue: 0.12).opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 20, y: -10)
        )
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        StoryReadingView(story: Story.sampleStories[2])
    }
}
