//
//  StoryAudioPlayerView.swift
//  Moonly
//
//  Created by Assistant on 21.01.2026.
//

import SwiftUI
import AVFoundation
import Combine

struct StoryAudioPlayerView: View {
    
    let story: Story
    @ObservedObject var languageManager: LanguageManager
    
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var isPlaying = false
    @State private var currentLanguage: AppLanguage
    
    // Initializer
    init(story: Story, languageManager: LanguageManager = .shared) {
        self.story = story
        self.languageManager = languageManager
        _currentLanguage = State(initialValue: languageManager.currentLanguage)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Story Title
            Text(story.title(for: currentLanguage))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            // Play/Pause Button
            Button(action: togglePlayback) {
                ZStack {
                    Circle()
                        .fill(Color.blue.gradient)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            // Progress Bar
            if let duration = audioPlayer.duration, duration > 0 {
                VStack(spacing: 8) {
                    ProgressView(value: audioPlayer.currentTime, total: duration)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                    
                    HStack {
                        Text(formatTime(audioPlayer.currentTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatTime(duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Story Pages
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(story.chapters(for: currentLanguage)) { chapter in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Chapter \(chapter.number): \(chapter.title)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(chapter.content)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            currentLanguage = languageManager.currentLanguage
            loadAudio()
        }
        .onChange(of: languageManager.currentLanguage) { oldValue, newValue in
            currentLanguage = newValue
            // Dil değiştiğinde audio'yu yeniden yükle
            audioPlayer.stop()
            isPlaying = false
            loadAudio()
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    // MARK: - Methods
    
    private func loadAudio() {
        // Dile göre doğru audio dosyasını al
        guard let audioFileName = story.audioFile(for: currentLanguage) else {
            print("⚠️ Bu hikaye için \(currentLanguage.rawValue) dilinde audio dosyası yok")
            return
        }
        
        // Dosya adından extension'ı ayır
        let fileNameWithoutExt = (audioFileName as NSString).deletingPathExtension
        let fileExtension = (audioFileName as NSString).pathExtension.isEmpty ? "mp3" : (audioFileName as NSString).pathExtension
        
        // Dil klasörü yolunu oluştur
        let languageFolder = currentLanguage == .turkish ? "tr" : "en"
        
        // Bundle içinde dil klasöründe ara (Audio/tr/ veya Audio/en/)
        if let bundleURL = Bundle.main.url(forResource: "Audio/\(languageFolder)/\(fileNameWithoutExt)", withExtension: fileExtension) {
            print("✅ Bundle'dan audio yükleniyor: Audio/\(languageFolder)/\(audioFileName)")
            print("📂 URL: \(bundleURL.path)")
            audioPlayer.load(url: bundleURL)
            return
        }
        
        // Bundle'ın kök dizininde ara (backward compatibility)
        if let bundleURL = Bundle.main.url(forResource: fileNameWithoutExt, withExtension: fileExtension) {
            print("✅ Bundle kök dizininden audio yükleniyor: \(audioFileName)")
            print("📂 URL: \(bundleURL.path)")
            audioPlayer.load(url: bundleURL)
            return
        }
        
        print("❌ Audio dosyası bulunamadı:")
        print("   - Bundle (dil klasörü): Audio/\(languageFolder)/\(fileNameWithoutExt).\(fileExtension)")
        print("   - Bundle (kök): \(fileNameWithoutExt).\(fileExtension)")
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
        isPlaying.toggle()
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audio Player Manager

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    @Published var currentTime: Double = 0
    @Published var duration: Double?
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    func load(url: URL) {
        do {
            // Audio session'ı ayarla
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration
            
            print("✅ Audio yüklendi - Süre: \(audioPlayer?.duration ?? 0) saniye")
        } catch {
            print("❌ Audio yükleme hatası: \(error.localizedDescription)")
        }
    }
    
    func play() {
        audioPlayer?.play()
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        stopTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
        stopTimer()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentTime = 0
        stopTimer()
    }
}
