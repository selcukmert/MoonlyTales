//
//  StoryCardView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct StoryCardView: View {
    let story: Story
    let language: AppLanguage
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            if let imageName = story.cardImageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .clipped()
            } else {
                // Fallback gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.25, blue: 0.35),
                        Color(red: 0.15, green: 0.18, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 280)
            }
            
            // Gradient overlay for text readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.8)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Content - Only Title
            VStack(alignment: .leading, spacing: 0) {
                Text(story.title(for: language))
                    .font(.system(size: 19, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: 280)
        .contentShape(Rectangle())  // Make entire card tappable
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        StoryCardView(story: Story.sampleStories[0], language: .english)
            .padding()
    }
}
