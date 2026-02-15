//
//  OnboardingView.swift
//  Moonly
//
//  Created by AI Assistant on 21.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var childName: String = ""
    @State private var isAnimating: Bool = false
    @Binding var isOnboardingComplete: Bool
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.12),
                    Color(red: 0.08, green: 0.1, blue: 0.15),
                    Color(red: 0.12, green: 0.15, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Stars
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.7)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 0.6)
                    )
                    .opacity(isAnimating ? 1 : 0.3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1...2))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...1)),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Moon icon
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .animation(.easeOut(duration: 0.8), value: isAnimating)
                .padding(.bottom, 40)
                
                // Welcome text
                VStack(spacing: 12) {
                    Text(languageManager.currentLanguage == .turkish ? "Hoş Geldin!" : "Welcome!")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text(languageManager.currentLanguage == .turkish 
                         ? "Sihirli uyku hikayelerine hazır mısın?"
                         : "Ready for magical bedtime stories?")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)
                .padding(.bottom, 30)
                
                // Language selector
                HStack(spacing: 12) {
                    ForEach([AppLanguage.english, AppLanguage.turkish], id: \.self) { language in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                languageManager.currentLanguage = language
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text(language.flag)
                                    .font(.system(size: 20))
                                Text(language.displayName)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(languageManager.currentLanguage == language 
                                          ? Color.white.opacity(0.2)
                                          : Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                languageManager.currentLanguage == language
                                                    ? Color.white.opacity(0.4)
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 32)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
                .padding(.bottom, 40)
                
                // Input section
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(languageManager.currentLanguage == .turkish 
                             ? "Çocuğunuzun Adı"
                             : "Your Child's Name")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 4)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.5))
                                .frame(width: 24)
                            
                            ZStack(alignment: .leading) {
                                // Custom placeholder
                                if childName.isEmpty {
                                    Text(languageManager.currentLanguage == .turkish ? "Örn: Elif" : "e.g., Emma")
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                
                                // TextField with empty placeholder
                                TextField("", text: $childName)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.words)
                            }
                            
                            if !childName.isEmpty {
                                Button(action: {
                                    childName = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    // Continue button
                    Button(action: saveAndContinue) {
                        HStack(spacing: 12) {
                            Text(languageManager.currentLanguage == .turkish ? "Devam Et" : "Continue")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: childName.isEmpty 
                                            ? [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]
                                            : [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(
                            color: childName.isEmpty ? .clear : .blue.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .disabled(childName.isEmpty)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    
                    // Skip button
                    Button(action: skipOnboarding) {
                        Text(languageManager.currentLanguage == .turkish ? "Atla" : "Skip")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 8)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func saveAndContinue() {
        // Save child name
        UserDefaults.standard.set(childName.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "childName")
        
        // Mark onboarding as complete
        withAnimation(.easeOut(duration: 0.4)) {
            isOnboardingComplete = true
        }
    }
    
    private func skipOnboarding() {
        // Mark as skipped
        UserDefaults.standard.set(true, forKey: "onboardingSkipped")
        
        // Don't save name, just continue
        withAnimation(.easeOut(duration: 0.4)) {
            isOnboardingComplete = true
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .environmentObject(LanguageManager.shared)
}
