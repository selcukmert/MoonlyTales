//
//  TextToSpeechConverter.swift
//  Moonly
//
//  Created by Assistant on 21.01.2026.
//

import AVFoundation
import Foundation

class TextToSpeechConverter {
    
    // MARK: - Properties
    
    private let synthesizer = AVSpeechSynthesizer()
    private var audioRecorder: AVAudioRecorder?
    private var completion: ((URL?) -> Void)?
    
    // MARK: - Public Methods
    
    /// Converts text to speech and saves as MP3 file
    /// - Parameters:
    ///   - text: The text to convert to speech
    ///   - fileName: The name of the output file (without extension)
    ///   - completion: Callback with the URL of the saved file, or nil if failed
    func convertToMP3(text: String, fileName: String, completion: @escaping (URL?) -> Void) {
        self.completion = completion
        
        // Configure audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            completion(nil)
            return
        }
        
        // Create temporary file URL for recording
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)_temp.m4a")
        
        // Set up audio recorder settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: tempURL, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            // Create speech utterance
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.45 // Slower for bedtime stories
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            // Set up synthesizer delegate
            let delegate = SpeechDelegate { [weak self] in
                self?.finishRecording(tempURL: tempURL, fileName: fileName)
            }
            synthesizer.delegate = delegate
            
            // Keep delegate alive
            objc_setAssociatedObject(synthesizer, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            
            // Start speaking
            synthesizer.speak(utterance)
            
        } catch {
            print("Failed to set up audio recorder: \(error)")
            completion(nil)
        }
    }
    
    /// Converts story pages array to a single MP3 file
    /// - Parameters:
    ///   - pages: Array of story page texts
    ///   - fileName: The name of the output file (without extension)
    ///   - completion: Callback with the URL of the saved file, or nil if failed
    func convertStoryToMP3(pages: [String], fileName: String, completion: @escaping (URL?) -> Void) {
        // Join all pages with pauses
        let fullText = pages.joined(separator: " ... ")
        convertToMP3(text: fullText, fileName: fileName, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func finishRecording(tempURL: URL, fileName: String) {
        // Stop recording
        audioRecorder?.stop()
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
        
        // Get documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let finalURL = documentsPath.appendingPathComponent("\(fileName).m4a")
        
        // Move file to final location
        do {
            // Remove existing file if it exists
            if FileManager.default.fileExists(atPath: finalURL.path) {
                try FileManager.default.removeItem(at: finalURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: finalURL)
            print("Audio saved to: \(finalURL.path)")
            completion?(finalURL)
        } catch {
            print("Failed to move audio file: \(error)")
            completion?(nil)
        }
    }
}

// MARK: - Speech Delegate

private class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    
    private let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Wait a moment before finishing recording
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onFinish()
        }
    }
}

// MARK: - Story Model

struct ConvertedStory: Codable {
    let id: String
    let title_en: String
    let audio_file: String?
    let pages_en: [String]
}

struct StoriesData: Codable {
    let stories: [ConvertedStory]
}

// MARK: - Usage Example

extension TextToSpeechConverter {
    
    /// Example: Load stories from JSON and convert the first story to MP3
    static func convertFirstStoryFromJSON() {
        // Load JSON file
        guard let url = Bundle.main.url(forResource: "bedtime_stories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let storiesData = try? JSONDecoder().decode(StoriesData.self, from: data),
              let firstStory = storiesData.stories.first else {
            print("Failed to load stories")
            return
        }
        
        // Convert to speech
        let converter = TextToSpeechConverter()
        converter.convertStoryToMP3(pages: firstStory.pages_en, fileName: "little_bunny") { url in
            if let url = url {
                print("Successfully created MP3: \(url.path)")
                print("You can now use this file in your app!")
            } else {
                print("Failed to create MP3")
            }
        }
    }
}
