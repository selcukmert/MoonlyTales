//
//  StoryAudioGeneratorView.swift
//  Moonly
//
//  Created by Assistant on 21.01.2026.
//

import SwiftUI

struct StoryAudioGeneratorView: View {
    
    @State private var isGenerating = false
    @State private var generatedFileURL: URL?
    @State private var errorMessage: String?
    @State private var stories: [ConvertedStory] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if isGenerating {
                        HStack {
                            ProgressView()
                            Text("Generating audio...")
                                .padding(.leading, 8)
                        }
                    } else if let url = generatedFileURL {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✓ Audio file created successfully!")
                                .foregroundColor(.green)
                                .font(.headline)
                            
                            Text("Saved to:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(url.path)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.blue)
                                .lineLimit(nil)
                        }
                        .padding(.vertical, 4)
                    } else if let error = errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✗ Error")
                                .foregroundColor(.red)
                                .font(.headline)
                            
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Available Stories") {
                    ForEach(stories, id: \.id) { story in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.title_en)
                                .font(.headline)
                            
                            Text("\(story.pages_en.count) pages")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let audioFile = story.audio_file {
                                Text("Audio file: \(audioFile)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            generateAudio(for: story)
                        }
                    }
                }
                
                Section("Instructions") {
                    Text("Tap on a story above to generate its MP3 audio file. The file will be saved to your app's documents directory.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Audio Generator")
            .onAppear {
                loadStories()
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadStories() {
        guard let url = Bundle.main.url(forResource: "bedtime_stories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let storiesData = try? JSONDecoder().decode(StoriesData.self, from: data) else {
            errorMessage = "Failed to load stories from JSON"
            return
        }
        
        stories = storiesData.stories
    }
    
    private func generateAudio(for story: ConvertedStory) {
        isGenerating = true
        errorMessage = nil
        generatedFileURL = nil
        
        let fileName = story.audio_file?.replacingOccurrences(of: ".mp3", with: "") ?? story.id
        
        let converter = TextToSpeechConverter()
        converter.convertStoryToMP3(pages: story.pages_en, fileName: fileName) { url in
            DispatchQueue.main.async {
                isGenerating = false
                
                if let url = url {
                    generatedFileURL = url
                } else {
                    errorMessage = "Failed to generate audio file"
                }
            }
        }
    }
}

#Preview {
    StoryAudioGeneratorView()
}
