//
//  StoryCardView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct StoryCardView: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // Icon container
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: story.iconName)
                        .font(.system(size: 35))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Read time badge
                HStack(spacing: 4) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 10))
                    Text("\(story.readTime) min read")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(story.title)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                
                Text(story.description)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(white: 0.15, opacity: 0.5))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        StoryCardView(story: Story.sampleStories[0])
            .padding()
    }
}
