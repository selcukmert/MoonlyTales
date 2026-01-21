//
//  StoryDetailView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @State private var isFavorite = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient with stars
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.35, blue: 0.45),
                    Color(red: 0.15, green: 0.2, blue: 0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Stars background
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat.random(in: 0...600)
                    )
            }
            
            // Forest silhouette at bottom
            VStack {
                Spacer()
                
                ForestSilhouetteView()
                    .frame(height: 300)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { isFavorite.toggle() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Tags
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "moon.fill")
                                .font(.system(size: 12))
                            Text("BEDTIME STORY")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(0.5)
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                        )
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                            Text("\(story.readTime) MINS")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(0.5)
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                        )
                        
                        Spacer()
                    }
                    
                    // Title
                    Text(story.title)
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .lineLimit(3)
                    
                    // Author
                    Text("Written by  \(story.author)")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Description
                    Text(story.fullDescription)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(6)
                        .padding(.top, 8)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        NavigationLink(destination: StoryReadingView(story: story)) {
                            HStack(spacing: 10) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 18))
                                Text("Read")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                        
                        Button(action: {}) {
                            HStack(spacing: 10) {
                                Image(systemName: "headphones")
                                    .font(.system(size: 18))
                                Text("Listen")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.blue)
                            )
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

struct ForestSilhouetteView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Gradient fade
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0.1, green: 0.15, blue: 0.25).opacity(0.8),
                        Color(red: 0.08, green: 0.12, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Tree silhouettes
                HStack(alignment: .bottom, spacing: -20) {
                    TreeShape(height: 180)
                    TreeShape(height: 220)
                    TreeShape(height: 160)
                    TreeShape(height: 200)
                    TreeShape(height: 140)
                    TreeShape(height: 190)
                    TreeShape(height: 170)
                    TreeShape(height: 210)
                }
                .foregroundColor(Color(red: 0.05, green: 0.08, blue: 0.15))
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct TreeShape: View {
    let height: CGFloat
    
    var body: some View {
        // Simple triangle tree shape
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 20, y: height))
                path.addLine(to: CGPoint(x: 10, y: height * 0.3))
                path.addLine(to: CGPoint(x: 30, y: height * 0.3))
                path.closeSubpath()
            }
            
            Path { path in
                path.move(to: CGPoint(x: 20, y: height * 0.5))
                path.addLine(to: CGPoint(x: 5, y: 0))
                path.addLine(to: CGPoint(x: 35, y: 0))
                path.closeSubpath()
            }
            
            Rectangle()
                .frame(width: 6, height: height * 0.15)
                .offset(y: height * 0.42)
        }
        .frame(height: height)
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(story: Story.sampleStories[2])
    }
}
