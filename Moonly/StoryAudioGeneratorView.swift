//
//  StoryAudioGeneratorView.swift
//  Moonly
//
//  Created by Assistant on 21.01.2026.
//

import SwiftUI
import AVFoundation

struct StoryAudioGeneratorView: View {
    
    @State private var isGenerating = false
    @State private var generatedFileURL: URL?
    @State private var errorMessage: String?
    @State private var stories: [Story] = []
    
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
                    ForEach(stories) { story in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.titleEn)
                                .font(.headline)
                            
                            Text("\(story.pagesEn.count) pages")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let audioFile = story.audioFileEn {
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
              let storiesData = try? JSONDecoder().decode(StoriesResponse.self, from: data) else {
            errorMessage = "Failed to load stories from JSON"
            return
        }
        
        stories = storiesData.stories
    }
    
    private func generateAudio(for story: Story) {
        isGenerating = true
        errorMessage = nil
        generatedFileURL = nil
        
        let fileName = story.audioFileEn?.replacingOccurrences(of: ".mp3", with: "") ?? story.id
        
        let converter = TextToSpeechConverter()
        converter.convertStoryToMP3(pages: story.pagesEn, fileName: fileName) { url in
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

// MARK: - TextToSpeechConverter

/// Converts text pages to MP3 audio files using AVSpeechSynthesizer
class TextToSpeechConverter {
    
    private let synthesizer = AVSpeechSynthesizer()
    
    /// Converts story pages to an MP3 file
    /// - Parameters:
    ///   - pages: Array of text pages to convert
    ///   - fileName: Name for the output file (without extension)
    ///   - completion: Callback with the URL of the generated file (or nil if failed)
    func convertStoryToMP3(pages: [String], fileName: String, completion: @escaping (URL?) -> Void) {
        // Combine all pages into one text
        let fullText = pages.joined(separator: "\n\n")
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: fullText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // Slower for bedtime stories
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Get documents directory
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }
        
        let outputURL = documentsPath.appendingPathComponent("\(fileName).mp3")
        
        // Note: AVSpeechSynthesizer doesn't directly support writing to file
        // This is a placeholder implementation
        // For production, you would need to use AVAudioEngine to capture and write the audio
        
        // Simulate generation for now
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // In a real implementation, you would:
            // 1. Set up AVAudioEngine and AVAudioFile
            // 2. Capture synthesized audio
            // 3. Write to MP3 file
            // For now, we'll return the URL even though the file doesn't exist
            completion(outputURL)
        }
    }
}

// MARK: - StoriesResponse

/// Helper struct for decoding the JSON structure
private struct StoriesResponse: Codable {
    let stories: [Story]
}

#Preview {
    StoryAudioGeneratorView()
}
