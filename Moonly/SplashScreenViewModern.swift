import SwiftUI
import Lottie

struct SplashScreenView: View {
    @State private var isAnimationComplete = false
    
    var body: some View {
        if isAnimationComplete {
            // Your main content view
            ContentView()
                .transition(.opacity)
        } else {
            ZStack {
                // Background color matching the Lottie animation theme
                Color(red: 0.259, green: 0.261, blue: 0.463)
                    .ignoresSafeArea()
                
                // Lottie animation
                LottieView(animation: .named("baby"))
                    .playing(loopMode: .playOnce)
                    .animationSpeed(1.0)
                    .frame(width: 300, height: 300)
            }
            .task {
                // Dismiss splash screen after 2500ms using modern async/await
                try? await Task.sleep(for: .milliseconds(2500))
                withAnimation(.easeOut(duration: 0.3)) {
                    isAnimationComplete = true
                }
            }
        }
    }
}

// Placeholder for your main content
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Main App Content")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    SplashScreenView()
}
