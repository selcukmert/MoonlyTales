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
    
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Story Title
            Text(story.title)
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
                    ForEach(story.chapters) { chapter in
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
            loadAudio()
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    // MARK: - Methods
    
    private func loadAudio() {
        // 1. Önce story'nin kendi audio dosyası var mı kontrol et (Bundle içinde)
        if let audioFileName = story.audioFile {
            // Dosya adından extension'ı ayır
            let fileNameWithoutExt = (audioFileName as NSString).deletingPathExtension
            let fileExtension = (audioFileName as NSString).pathExtension.isEmpty ? "mp3" : (audioFileName as NSString).pathExtension
            
            if let bundleURL = Bundle.main.url(forResource: fileNameWithoutExt, withExtension: fileExtension) {
                print("✅ Bundle'dan audio yükleniyor: \(audioFileName)")
                print("📂 URL: \(bundleURL.path)")
                audioPlayer.load(url: bundleURL)
                return
            } else {
                print("⚠️ Bundle'da dosya bulunamadı: \(fileNameWithoutExt).\(fileExtension)")
                print("📁 Bundle path: \(Bundle.main.bundlePath)")
            }
        }
        
        // 2. Documents klasöründe TTS ile oluşturulmuş audio var mı kontrol et
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = "\(story.id).m4a"
        let audioURL = documentsPath.appendingPathComponent(audioFileName)
        
        if FileManager.default.fileExists(atPath: audioURL.path) {
            print("✅ Documents'tan TTS audio yükleniyor: \(audioFileName)")
            audioPlayer.load(url: audioURL)
            return
        }
        
        print("⚠️ Hiçbir audio dosyası bulunamadı.")
        print("   Bundle audio: \(story.audioFile ?? "yok")")
        print("   TTS audio: \(audioFileName) (yok)")
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
