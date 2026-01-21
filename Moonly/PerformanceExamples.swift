//
//  PerformanceExamples.swift
//  Moonly - Performance Patterns
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

// MARK: - Example 1: Story Detail View with Instant Response

struct StoryDetailViewExample: View {
    let story: Story
    @StateObject private var ttsManager = SpeechManager()
    
    var body: some View {
        VStack(spacing: 24) {
            // Story preview
            Text(story.titleEn)
                .font(.title)
            
            // Status indicator
            if ttsManager.isPreparingContent {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Preparing story...")
                        .font(.caption)
                }
            }
            
            // Play/Pause button with instant response
            Button {
                ttsManager.togglePlayPause()
            } label: {
                HStack {
                    Image(systemName: buttonIcon)
                    Text(buttonTitle)
                }
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(ttsManager.isPreparingContent)
            
            // Progress
            if ttsManager.isPlaying {
                VStack {
                    ProgressView(
                        value: ttsManager.currentTime,
                        total: ttsManager.totalTime
                    )
                    
                    Text("\(Int(ttsManager.currentTime))s / \(Int(ttsManager.totalTime))s")
                        .font(.caption)
                }
                .padding()
            }
        }
        .padding()
        .task {
            // Prepare content as soon as view appears
            await ttsManager.prepareContent(
                text: story.contentEn,
                language: .english
            )
        }
        .onDisappear {
            ttsManager.stop()
        }
    }
    
    private var buttonIcon: String {
        if ttsManager.isPlaying && !ttsManager.isPaused {
            return "pause.circle.fill"
        } else {
            return "play.circle.fill"
        }
    }
    
    private var buttonTitle: String {
        if ttsManager.isPreparingContent {
            return "Preparing..."
        } else if ttsManager.isPlaying && !ttsManager.isPaused {
            return "Pause"
        } else {
            return "Play"
        }
    }
}

// MARK: - Example 2: Reader View with Async Loading

struct ReaderViewExample: View {
    let story: Story
    let language: AppLanguage
    @StateObject private var viewModel = ReaderViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoaded {
                // Show content once loaded
                ScrollView {
                    Text(viewModel.content)
                        .foregroundColor(.white)
                        .padding()
                }
                .transition(.opacity)
            } else {
                // Show skeleton while loading
                LoadingSkeleton()
                    .transition(.opacity)
            }
        }
        .task {
            // Load asynchronously
            await viewModel.loadContent(story: story, language: language)
        }
    }
}

@MainActor
class ReaderViewModel: ObservableObject {
    @Published var isLoaded = false
    @Published var content: String = ""
    
    func loadContent(story: Story, language: AppLanguage) async {
        // Simulate heavy processing (e.g., formatting, parsing)
        await Task.detached(priority: .userInitiated) {
            // Heavy work here (off main thread)
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }.value
        
        // Update UI on main thread
        content = language == .turkish ? story.contentTr : story.contentEn
        
        // Add small delay for transition
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        withAnimation {
            isLoaded = true
        }
    }
}

struct LoadingSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<10, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 20)
            }
        }
        .padding()
    }
}

// MARK: - Example 3: Optimistic Button Pattern

struct OptimisticButtonExample: View {
    @State private var isLiked = false
    @State private var likeCount = 42
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(likeCount) likes")
                .font(.title2)
            
            Button {
                // OPTIMISTIC: Update UI immediately
                let wasLiked = isLiked
                isLiked.toggle()
                likeCount += isLiked ? 1 : -1
                
                // Then perform actual operation
                Task {
                    do {
                        try await performLikeAction(liked: isLiked)
                    } catch {
                        // Revert on error
                        isLiked = wasLiked
                        likeCount += wasLiked ? 1 : -1
                    }
                }
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 40))
                    .foregroundColor(isLiked ? .red : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
    }
    
    private func performLikeAction(liked: Bool) async throws {
        // Simulate network call
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - Example 4: Heavy Text Processing Pattern

@MainActor
class TextProcessorViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var processedChunks: [String] = []
    
    func processLargeText(_ text: String) async {
        isProcessing = true
        
        // Process in background
        let chunks = await Task.detached(priority: .userInitiated) {
            // Heavy regex or text manipulation
            return self.splitIntoChunks(text)
        }.value
        
        // Update UI
        processedChunks = chunks
        isProcessing = false
    }
    
    private func splitIntoChunks(_ text: String) -> [String] {
        // Expensive operation (off main thread)
        let pattern = "(?<=[.!?])\\s+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [text]
        }
        
        // ... processing logic ...
        
        return text.components(separatedBy: .newlines)
    }
}

// MARK: - Example 5: Progressive Loading Pattern

struct ProgressiveLoadingExample: View {
    @StateObject private var viewModel = ProgressiveViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Essential content (always visible)
                Text("Story Title")
                    .font(.largeTitle)
                
                // Primary content (loads first)
                if viewModel.primaryLoaded {
                    Text(viewModel.primaryContent)
                        .transition(.opacity)
                } else {
                    ProgressView()
                }
                
                // Secondary content (loads after)
                if viewModel.secondaryLoaded {
                    Text(viewModel.secondaryContent)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
                
                // Tertiary content (loads last)
                if viewModel.tertiaryLoaded {
                    Text(viewModel.tertiaryContent)
                        .font(.caption)
                        .transition(.opacity)
                }
            }
            .padding()
        }
        .task(priority: .userInitiated) {
            await viewModel.loadContent()
        }
    }
}

@MainActor
class ProgressiveViewModel: ObservableObject {
    @Published var primaryLoaded = false
    @Published var secondaryLoaded = false
    @Published var tertiaryLoaded = false
    
    @Published var primaryContent = ""
    @Published var secondaryContent = ""
    @Published var tertiaryContent = ""
    
    func loadContent() async {
        // Load in priority order
        
        // 1. Critical content first (instant)
        primaryContent = await loadPrimaryContent()
        withAnimation {
            primaryLoaded = true
        }
        
        // 2. Important content (quick)
        secondaryContent = await loadSecondaryContent()
        withAnimation {
            secondaryLoaded = true
        }
        
        // 3. Optional content (can wait)
        tertiaryContent = await loadTertiaryContent()
        withAnimation {
            tertiaryLoaded = true
        }
    }
    
    private func loadPrimaryContent() async -> String {
        // Fast loading
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        return "Main story content here..."
    }
    
    private func loadSecondaryContent() async -> String {
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        return "Additional details..."
    }
    
    private func loadTertiaryContent() async -> String {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        return "Extra information..."
    }
}

// MARK: - Example 6: Correct State Management

enum PlaybackState {
    case idle
    case preparing
    case playing
    case paused
    
    var buttonTitle: String {
        switch self {
        case .idle: return "Play"
        case .preparing: return "Loading..."
        case .playing: return "Pause"
        case .paused: return "Resume"
        }
    }
    
    var buttonIcon: String {
        switch self {
        case .idle, .paused: return "play.fill"
        case .preparing: return "hourglass"
        case .playing: return "pause.fill"
        }
    }
    
    var isButtonDisabled: Bool {
        self == .preparing
    }
}

struct StateBasedPlayerExample: View {
    @State private var playbackState: PlaybackState = .idle
    
    var body: some View {
        VStack(spacing: 20) {
            // State display
            Text("State: \(String(describing: playbackState))")
                .font(.caption)
            
            // Button that responds to state
            Button {
                handlePlayPause()
            } label: {
                HStack {
                    Image(systemName: playbackState.buttonIcon)
                    Text(playbackState.buttonTitle)
                }
                .frame(width: 200, height: 50)
                .background(playbackState.isButtonDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(playbackState.isButtonDisabled)
        }
    }
    
    private func handlePlayPause() {
        switch playbackState {
        case .idle:
            startPlayback()
        case .playing:
            pausePlayback()
        case .paused:
            resumePlayback()
        case .preparing:
            break // Disabled
        }
    }
    
    private func startPlayback() {
        // OPTIMISTIC: Update state immediately
        playbackState = .preparing
        
        Task {
            // Prepare content
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Start playing
            playbackState = .playing
        }
    }
    
    private func pausePlayback() {
        // INSTANT: No async work needed
        playbackState = .paused
    }
    
    private func resumePlayback() {
        // INSTANT: No async work needed
        playbackState = .playing
    }
}

// MARK: - Performance Measurement Helper

struct PerformanceMeasured<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    
    init(_ label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        let start = Date()
        let result = content()
        let duration = Date().timeIntervalSince(start)
        
        print("⏱️ [\(label)] Body computed in \(duration * 1000)ms")
        
        return result
    }
}

// Usage:
// PerformanceMeasured("MyView") {
//     MyExpensiveView()
// }

// MARK: - Previews

#Preview("Story Detail") {
    StoryDetailViewExample(story: Story.sampleStories[0])
}

#Preview("Optimistic Button") {
    OptimisticButtonExample()
}

#Preview("State-Based Player") {
    StateBasedPlayerExample()
}

#Preview("Progressive Loading") {
    ProgressiveLoadingExample()
}
