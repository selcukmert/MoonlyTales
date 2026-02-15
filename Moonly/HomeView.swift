//
//  HomeView.swift
//  Moonly
//

import SwiftUI

struct HomeView: View {
    @State private var stories: [Story] = []
    @EnvironmentObject private var languageManager: LanguageManager
    
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
                                
                                if let childName = UserDefaults.standard.string(forKey: "childName"), !childName.isEmpty {
                                    // With child name
                                    Text(languageManager.currentLanguage == .english 
                                         ? "GOOD EVENING, \(childName.uppercased())"
                                         : "İYİ AKŞAMLAR, \(childName.uppercased())")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                        .tracking(1)
                                } else {
                                    // Without child name
                                    Text(languageManager.currentLanguage == .english ? "GOOD EVENING" : "İYİ AKŞAMLAR")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                        .tracking(1)
                                }
                                
                                Spacer()
                                
                                // Dil değiştirme butonu
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        languageManager.toggleLanguage()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Text(languageManager.currentLanguage.flag)
                                            .font(.system(size: 16))
                                        Text(languageManager.currentLanguage.displayName)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.15))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Story cards - 2 column grid
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(stories) { story in
                                NavigationLink {
                                    StoryDetailView(story: story)
                                } label: {
                                    StoryCardView(story: story, language: languageManager.currentLanguage)
                                }
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
        .environmentObject(LanguageManager.shared)
        .onAppear {
            print("🎬 Preview başlatıldı")
        }
}
