//
//  StoryDetailView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
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
                    
                    // Description (first page preview)
                    Text(story.description)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(6)
                        .padding(.top, 8)
                    
                    // Action button
                    NavigationLink(destination: StoryReadingView(story: story)) {
                        HStack(spacing: 10) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 18))
                            Text("Read")
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
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .swipeBack()  // Enable swipe-back gesture with visual indicator
    }
}


#Preview {
    NavigationStack {
        StoryDetailView(story: Story.sampleStories[0])
    }
}
