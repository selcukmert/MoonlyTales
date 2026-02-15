import SwiftUI
import Lottie

struct SplashScreenView: View {
    @State private var isAnimationComplete = false
    @State private var isOnboardingComplete = false
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        Group {
            if isAnimationComplete {
                if isOnboardingComplete || hasCompletedOnboarding {
                    HomeView()
                        .transition(.opacity)
                } else {
                    OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                        .transition(.opacity)
                }
            } else {
                splashContent
            }
        }
    }
    
    private var hasCompletedOnboarding: Bool {
        // Check if user has already completed onboarding
        UserDefaults.standard.string(forKey: "childName") != nil ||
        UserDefaults.standard.bool(forKey: "onboardingSkipped")
    }
    
    private var splashContent: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.12),
                    Color(red: 0.08, green: 0.1, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                LottieView(animation: .named("baby"))
                    .playing(loopMode: .loop)
                    .animationSpeed(0.8)
                    .frame(width: 200, height: 200)
                    .opacity(logoOpacity)
                Text("Moonly")
                    .font(.system(size: 52, weight: .semibold, design: .serif))
                    .foregroundColor(.white)
                    .tracking(2)
                    .opacity(textOpacity)
                Text("SWEET DREAMS")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(3)
                    .opacity(textOpacity)
                
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.3)))
                    .scaleEffect(0.8)
                    .padding(.bottom, 60)
                    .opacity(textOpacity)
            }
        }
        .task {
            withAnimation(.easeOut(duration: 0.8)) {
                logoOpacity = 1.0
            }
            
            try? await Task.sleep(for: .milliseconds(400))
            
            withAnimation(.easeOut(duration: 0.8)) {
                textOpacity = 1.0
            }
            
            try? await Task.sleep(for: .milliseconds(2100))
            withAnimation(.easeOut(duration: 0.4)) {
                isAnimationComplete = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
