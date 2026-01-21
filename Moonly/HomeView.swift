//
//  HomeView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct HomeView: View {
    @State private var stories = Story.sampleStories
    
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
                                
                                Button(action: {}) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            Text("Sleep well, Alex")
                                .font(.system(size: 42, weight: .bold, design: .serif))
                                .foregroundColor(.white)
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
                        .padding(.bottom, 100)
                    }
                }
                
                // Bottom navigation bar
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        TabBarButton(icon: "house.fill", isSelected: true)
                        Spacer()
                        TabBarButton(icon: "heart", isSelected: false)
                        Spacer()
                        TabBarButton(icon: "magnifyingglass", isSelected: false)
                        Spacer()
                        TabBarButton(icon: "gearshape", isSelected: false)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(white: 0.1, opacity: 0.8))
                            .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color.blue : Color.white.opacity(0.4))
                .frame(width: 44, height: 44)
        }
    }
}

#Preview {
    HomeView()
}
