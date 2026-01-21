//
//  HomeView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct HomeView: View {
    @State private var stories: [Story] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(red: 0.08, green: 0.1, blue: 0.12)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("GOOD EVENING")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .tracking(1)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Story cards
                        VStack(spacing: 16) {
                            ForEach(stories) { story in
                                NavigationLink(destination: StoryDetailView(story: story)) {
                                    StoryCardView(story: story)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .onAppear {
                if stories.isEmpty {
                    stories = StoryLoader.loadStories()
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .onAppear {
            print("🎬 Preview başlatıldı")
        }
}
