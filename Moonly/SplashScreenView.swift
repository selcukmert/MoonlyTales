import SwiftUI
import Lottie

struct SplashScreenView: View {
    @State private var isAnimationComplete = false
    
    var body: some View {
        if isAnimationComplete {
            // Your main content view
            ContentView()
        } else {
            ZStack {
                // Background color
                Color(red: 0.259, green: 0.261, blue: 0.463)
                    .ignoresSafeArea()
                
                // Lottie animation
                LottieView(animation: .named("baby"))
                    .playing(loopMode: .playOnce)
                    .animationSpeed(1.0)
                    .frame(width: 300, height: 300)
            }
            .onAppear {
                // Dismiss splash screen after 2500ms
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isAnimationComplete = true
                    }
                }
            }
        }
    }
}

// Placeholder for your main content
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Main App Content")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SplashScreenView()
}
