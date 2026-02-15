//
//  StoryReadingView.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI
import AVFoundation
import Combine

/// Production-ready audio manager supporting both MP3 playback and TTS
/// Designed for instant UI responsiveness and background processing
@MainActor
class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    // MARK: - Published Properties (UI State)
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var currentSentenceIndex: Int = 0
    @Published var isPreparingContent = false
    @Published var errorMessage: String?
    @Published var isBackgroundMusicPlaying = false
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var backgroundPlayer: AVAudioPlayer?
    private var storyAudioPlayer: AVAudioPlayer?  // MP3 player için
    private var timer: Timer?
    private var sentences: [String] = []
    private var currentLanguage: AppLanguage = .english
    private var utteranceStartTime: Date?
    private var accumulatedTime: TimeInterval = 0
    private var preparationTask: Task<Void, Never>?
    private var isUsingMp3: Bool = false  // MP3 mi TTS mi kullanıldığını takip et
    
    // Speech rate optimized for children's bedtime stories
    private let speechRates: [AppLanguage: Float] = [
        .turkish: 0.35,
        .english: 0.40
    ]
    
    // MARK: - Initialization
    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured for TTS + background audio")
        } catch {
            print("❌ Audio session error: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Prepare content asynchronously - supports both MP3 and TTS
    func prepareContent(text: String, language: AppLanguage, audioFile: String? = nil) async {
        // Cancel any existing preparation
        preparationTask?.cancel()
        
        isPreparingContent = true
        errorMessage = nil
        
        // ÖNEMLİ: Dili hemen ayarla (MP3 yükleme için gerekli)
        self.currentLanguage = language
        
        // Also prepare background music
        prepareBackgroundMusic()
        
        // 1. Önce MP3 dosyası var mı kontrol et
        if let audioFileName = audioFile {
            if await loadMP3(fileName: audioFileName) {
                isPreparingContent = false
                return // MP3 yüklendi, TTS'e gerek yok
            }
        }
        
        // 2. MP3 yoksa TTS kullan
        isUsingMp3 = false
        preparationTask = Task { @MainActor in
            // Process text in background
            let sentences = await splitIntoSentencesAsync(text)
            
            guard !Task.isCancelled else {
                isPreparingContent = false
                return
            }
            
            // Store results
            self.sentences = sentences
            
            // Calculate total time
            let words = text.components(separatedBy: .whitespaces).count
            let wordsPerSecond: Double = language == .turkish ? 1.4 : 1.6
            let pauseTime = Double(sentences.count) * 0.6
            self.totalTime = (Double(words) / wordsPerSecond) + pauseTime
            
            self.isPreparingContent = false
        }
        
        await preparationTask?.value
    }
    
    /// Load MP3 file from bundle
    /// Supports both filename suffixes (_tr) and folder structure
    private func loadMP3(fileName: String) async -> Bool {
        let fileNameWithoutExt = (fileName as NSString).deletingPathExtension
        let fileExtension = (fileName as NSString).pathExtension.isEmpty ? "mp3" : (fileName as NSString).pathExtension
        
        var bundleURL: URL?
        
        // ÖNCE: Verilen dosya adını direkt dene (örn: little_bunny_tr.mp3)
        // Bu şekilde JSON'daki tam dosya adı kullanılır
        bundleURL = Bundle.main.url(
            forResource: fileNameWithoutExt,
            withExtension: fileExtension,
            subdirectory: "Audio"
        )
        
        // Audio/ klasöründe bulunamadıysa root'ta ara
        if bundleURL == nil {
            bundleURL = Bundle.main.url(forResource: fileNameWithoutExt, withExtension: fileExtension)
        }
        
        // YEDEK: Dil klasörü yapısını dene (gelecekteki kullanım için)
        if bundleURL == nil {
            let languageFolder = currentLanguage == .turkish ? "tr" : "en"
            bundleURL = Bundle.main.url(
                forResource: fileNameWithoutExt,
                withExtension: fileExtension,
                subdirectory: "Audio/\(languageFolder)"
            )
        }
        
        guard let bundleURL = bundleURL else {
            print("⚠️ Bundle'da MP3 bulunamadı: \(fileNameWithoutExt).\(fileExtension)")
            print("   Aranan dosya: \(fileName)")
            print("   Dil: \(currentLanguage)")
            return false
        }
        
        print("✅ Bundle'dan audio yükleniyor: \(bundleURL.lastPathComponent) (Dil: \(currentLanguage))")
        
        do {
            // Audio session'ı ayarla
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            
            storyAudioPlayer = try AVAudioPlayer(contentsOf: bundleURL)
            storyAudioPlayer?.prepareToPlay()
            totalTime = storyAudioPlayer?.duration ?? 0
            isUsingMp3 = true
            
            print("✅ MP3 yüklendi: \(fileName) - Süre: \(totalTime)s")
            return true
        } catch {
            print("❌ MP3 yükleme hatası: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Start or toggle playback - supports both MP3 and TTS
    func play() {
        guard !isPreparingContent else {
            errorMessage = "Still preparing content..."
            return
        }
        
        // MP3 modunda
        if isUsingMp3 {
            playMP3()
            return
        }
        
        // TTS modunda
        guard !sentences.isEmpty else {
            errorMessage = "No content to play"
            return
        }
        
        // OPTIMISTIC UI UPDATE - instant feedback
        if isPaused {
            // Resume from pause
            isPaused = false
            isPlaying = true
            startProgressTimer()
            
            // Resume background music
            resumeBackgroundMusic()
            
            // Actual resume happens on synthesizer (fast)
            synthesizer.continueSpeaking()
        } else if !isPlaying {
            // Start new playback
            isPlaying = true
            isPaused = false
            currentTime = 0
            accumulatedTime = 0
            currentSentenceIndex = 0
            
            // Start speaking (synthesizer call is fast)
            startProgressTimer()
            speakNextSentence()
        }
        
        errorMessage = nil
    }
    
    /// Pause playback - supports both MP3 and TTS
    func pause() {
        guard isPlaying && !isPaused else { return }
        
        // OPTIMISTIC UI UPDATE - instant feedback
        isPaused = true
        stopProgressTimer()
        
        // Pause background music
        pauseBackgroundMusic()
        
        // MP3 modunda
        if isUsingMp3 {
            storyAudioPlayer?.pause()
        } else {
            // TTS modunda
            synthesizer.pauseSpeaking(at: .word)
        }
    }
    
    /// Play MP3 audio
    private func playMP3() {
        guard let player = storyAudioPlayer else {
            errorMessage = "MP3 player not initialized"
            return
        }
        
        if isPaused {
            // Resume from pause
            isPaused = false
            isPlaying = true
            player.play()
            startMP3ProgressTimer()
            resumeBackgroundMusic()
        } else if !isPlaying {
            // Start new playback
            isPlaying = true
            isPaused = false
            currentTime = 0
            player.currentTime = 0
            player.play()
            startMP3ProgressTimer()
            startBackgroundMusic()
        }
        
        errorMessage = nil
    }
    
    /// Progress timer for MP3 playback
    private func startMP3ProgressTimer() {
        stopProgressTimer() // Clear existing timer
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.storyAudioPlayer else { return }
            
            Task { @MainActor in
                self.currentTime = player.currentTime
                
                // Stop when finished
                if !player.isPlaying && self.currentTime > 0 {
                    self.isPlaying = false
                    self.stopProgressTimer()
                    self.stopBackgroundMusic()
                }
            }
        }
    }
    
    /// Toggle play/pause
    func togglePlayPause() {
        if isPlaying && !isPaused {
            pause()
        } else {
            play()
        }
    }
    
    /// Stop playback completely
    func stop() {
        // Cancel any preparation
        preparationTask?.cancel()
        
        // Stop MP3 or TTS
        if isUsingMp3 {
            storyAudioPlayer?.stop()
            storyAudioPlayer?.currentTime = 0
        } else {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        stopProgressTimer()
        
        // Stop background music
        stopBackgroundMusic()
        
        // Reset state
        isPlaying = false
        isPaused = false
        currentTime = 0
        accumulatedTime = 0
        currentSentenceIndex = 0
        isPreparingContent = false
    }
    
    // MARK: - Background Music Methods
    
    /// Prepare background music (loads but doesn't play yet)
    private func prepareBackgroundMusic() {
        print("🎵 Preparing background music...")
        
        guard let url = Bundle.main.url(forResource: "music_box", withExtension: "mp3") else {
            print("❌ Could not find music_box.mp3")
            return
        }
        
        print("✅ Found music_box.mp3")
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1  // Loop forever
            backgroundPlayer?.volume = 0.15       // Very subtle background
            backgroundPlayer?.prepareToPlay()
            print("✅ Background music prepared successfully")
        } catch {
            print("❌ Error loading background music: \(error)")
        }
    }
    
    /// Start background music playback
    private func startBackgroundMusic() {
        guard let player = backgroundPlayer else {
            print("❌ Background player not initialized")
            return
        }
        
        player.play()
        isBackgroundMusicPlaying = true
        print("🎵 Background music started (isPlaying: \(player.isPlaying))")
    }
    
    /// Pause background music
    private func pauseBackgroundMusic() {
        backgroundPlayer?.pause()
        isBackgroundMusicPlaying = false
        print("⏸️ Background music paused")
    }
    
    /// Resume background music
    private func resumeBackgroundMusic() {
        guard let player = backgroundPlayer else { return }
        
        player.play()
        isBackgroundMusicPlaying = true
        print("▶️ Background music resumed")
    }
    
    /// Stop background music
    private func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        isBackgroundMusicPlaying = false
        print("🛑 Background music stopped")
    }
    
    // MARK: - Private Methods
    
    /// Split text into sentences asynchronously (off main thread)
    private func splitIntoSentencesAsync(_ text: String) async -> [String] {
        return await Task.detached(priority: .userInitiated) {
            // Heavy regex processing happens here (off main thread)
            let pattern = "(?<=[.!?])\\s+"
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                return [text]
            }
            
            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, range: range)
            
            var sentences: [String] = []
            var lastEnd = text.startIndex
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let sentence = String(text[lastEnd..<range.lowerBound])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !sentence.isEmpty {
                        sentences.append(sentence)
                    }
                    lastEnd = range.upperBound
                }
            }
            
            // Add remaining text
            let lastSentence = String(text[lastEnd...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !lastSentence.isEmpty {
                sentences.append(lastSentence)
            }
            
            return sentences.isEmpty ? [text] : sentences
        }.value
    }
    
    /// Speak the next sentence (fast - already prepared)
    private func speakNextSentence() {
        guard currentSentenceIndex < sentences.count else {
            finishSpeaking()
            return
        }
        
        let sentence = sentences[currentSentenceIndex]
        let utterance = createUtterance(for: sentence)
        
        utteranceStartTime = Date()
        synthesizer.speak(utterance)
    }
    
    /// Create optimized utterance (fast)
    private func createUtterance(for text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        
        let languageCode = currentLanguage == .turkish ? "tr-TR" : "en-US"
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        
        utterance.rate = speechRates[currentLanguage] ?? 0.38
        utterance.pitchMultiplier = 0.95
        utterance.volume = 0.85
        
        utterance.preUtteranceDelay = currentSentenceIndex == 0 ? 0.3 : 0.5
        utterance.postUtteranceDelay = 0.6
        
        return utterance
    }
    
    /// Start progress timer (main thread)
    private func startProgressTimer() {
        stopProgressTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                guard self.isPlaying, !self.isPaused else { return }
                self.currentTime += 0.1
                
                if self.currentTime >= self.totalTime {
                    self.currentTime = self.totalTime
                }
            }
        }
    }
    
    /// Stop progress timer
    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Complete speaking session
    private func finishSpeaking() {
        Task { @MainActor in
            self.stopProgressTimer()
            self.currentTime = self.totalTime
            self.isPlaying = false
            self.isPaused = false
            self.currentSentenceIndex = 0
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.utteranceStartTime = Date()
            
            // Start background music when first sentence begins
            if self.currentSentenceIndex == 0 {
                self.startBackgroundMusic()
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            if let startTime = self.utteranceStartTime {
                self.accumulatedTime += Date().timeIntervalSince(startTime)
            }
            
            self.currentSentenceIndex += 1
            
            if self.currentSentenceIndex < self.sentences.count {
                self.speakNextSentence()
            } else {
                self.finishSpeaking()
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.stop()
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        // Pause confirmed by synthesizer
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        // Resume confirmed by synthesizer
    }
}

struct StoryReadingView: View {
    let story: Story
    @StateObject private var speechManager = SpeechManager()
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var contentLoaded = false
    
    var storyText: String {
        story.fullDescription(for: languageManager.currentLanguage)
    }
    
    var storyTitle: String {
        story.title(for: languageManager.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.08, green: 0.1, blue: 0.12)
                .ignoresSafeArea()
            
            // Main content with padding for bottom player
            VStack(spacing: 0) {
                if contentLoaded {
                    // Content view (shows once loaded)
                    contentView
                } else {
                    // Loading skeleton
                    loadingView
                }
            }
            
            // Top bar (always visible)
            topBar
            
            // Audio player fixed at bottom
            VStack {
                Spacer()
                
                AudioPlayerView(
                    isPlaying: $speechManager.isPlaying,
                    isPaused: $speechManager.isPaused,
                    currentTime: $speechManager.currentTime,
                    totalTime: speechManager.totalTime,
                    isPreparingContent: speechManager.isPreparingContent,
                    isBackgroundMusicPlaying: speechManager.isBackgroundMusicPlaying,
                    onPlayPause: {
                        speechManager.togglePlayPause()
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .task {
            // Prepare content asynchronously on appear
            await prepareContent()
        }
        .onChange(of: languageManager.currentLanguage) { oldLanguage, newLanguage in
            // Dil değiştiğinde ses dosyasını yeniden yükle
            Task {
                // Önce mevcut sesi durdur
                speechManager.stop()
                
                // Yeni dile göre içeriği yeniden hazırla
                await prepareContent()
                
                print("🌍 Dil değişti: \(oldLanguage) -> \(newLanguage)")
            }
        }
        .onDisappear {
            speechManager.stop()
        }
    }
    
    // MARK: - Subviews
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Chapter title
                VStack(alignment: .center, spacing: 8) {
                    Text(storyTitle.uppercased())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(2)
                    
                    Text(storyTitle)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
                .padding(.bottom, 20)
                
                // Story content
                Text(storyText)
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(12)
                    .padding(.horizontal, 24)
                
                Spacer(minLength: 200)
            }
        }
        .transition(.opacity.animation(.easeIn(duration: 0.2)))
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            // Title skeleton
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 200, height: 32)
            }
            .padding(.top, 120)
            
            // Content skeleton
            VStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 18)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .transition(.opacity)
    }
    
    private var topBar: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Content Preparation
    
    /// Prepare content asynchronously (non-blocking)
    private func prepareContent() async {
        // Show content immediately (fast)
        contentLoaded = true
        
        // Prepare audio in background - Dile göre doğru ses dosyasını kullan
        let audioFileName = story.audioFile(for: languageManager.currentLanguage)
        await speechManager.prepareContent(
            text: storyText, 
            language: languageManager.currentLanguage, 
            audioFile: audioFileName
        )
    }
}

struct AudioPlayerView: View {
    @Binding var isPlaying: Bool
    @Binding var isPaused: Bool
    @Binding var currentTime: TimeInterval
    let totalTime: TimeInterval
    let isPreparingContent: Bool
    let isBackgroundMusicPlaying: Bool
    let onPlayPause: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 4)
                        
                        // Progress track
                        Rectangle()
                            .fill(Color.blue)
                            .frame(
                                width: totalTime > 0 
                                    ? geometry.size.width * (currentTime / totalTime) 
                                    : 0,
                                height: 4
                            )
                            .animation(.linear(duration: 0.1), value: currentTime)
                    }
                }
                .frame(height: 4)
                
                // Time labels
                HStack {
                    Text(timeString(from: currentTime))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    // Status indicator
                    if isPreparingContent {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(.white.opacity(0.6))
                            Text("Preparing...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    Text(timeString(from: totalTime))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 24)
            
            // Play/Pause button with optimistic state
            Button(action: onPlayPause) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 70, height: 70)
                    
                    // Icon changes immediately based on state
                    if isPreparingContent {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: buttonIcon)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .offset(x: buttonIconOffset)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
            }
            .disabled(isPreparingContent)
            .opacity(isPreparingContent ? 0.5 : 1.0)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color(red: 0.08, green: 0.1, blue: 0.12))
                .shadow(color: .black.opacity(0.3), radius: 20, y: -10)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Computed Properties
    
    /// Determine button icon based on current state
    private var buttonIcon: String {
        if isPlaying && !isPaused {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }
    
    /// Icon offset for visual centering
    private var buttonIconOffset: CGFloat {
        if isPlaying && !isPaused {
            return 0
        } else {
            return 2  // Center the play triangle visually
        }
    }
    
    // MARK: - Helper Methods
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        StoryReadingView(story: Story.sampleStories[2])
            .environmentObject(LanguageManager.shared)
    }
}
