//
//  SwipeBackQuickStart.swift
//  Moonly - Quick Start Guide for Swipe Back
//
//  Created by Mert Selçuk on 21.01.2026.
//

import SwiftUI

/*
 
 ═══════════════════════════════════════════════════════════════
 📱 SWIPE BACK GESTURE - QUICK START GUIDE
 ═══════════════════════════════════════════════════════════════
 
 Add iOS-style swipe-to-dismiss gestures to any view with
 beautiful animations and visual feedback.
 
 ───────────────────────────────────────────────────────────────
 
 🎯 BASIC USAGE (30 seconds setup):
 
 struct MyView: View {
     var body: some View {
         VStack {
             Text("Your content here")
         }
         .navigationBarHidden(true)
         .swipeBack()  // ← Add this line!
     }
 }
 
 That's it! Now users can swipe right to go back.
 
 ───────────────────────────────────────────────────────────────
 
 ✨ WHAT YOU GET:
 
 ✅ Swipe-right-to-dismiss gesture
 ✅ Visual "Back" indicator during swipe
 ✅ Smooth spring animations
 ✅ Velocity detection (quick swipes)
 ✅ Natural resistance curve
 ✅ Works with NavigationStack
 
 ───────────────────────────────────────────────────────────────
 
 📖 ALL OPTIONS:
 
 // 1. Basic (with visual indicator)
 .swipeBack()
 
 // 2. Custom threshold
 .swipeBack(threshold: 150)
 
 // 3. With dismiss callback
 .swipeBack {
     // Clean up before going back
     // yourAudioManager.stop()
 }
 
 // 4. Both custom threshold + callback
 .swipeBack(threshold: 150) {
     // yourAudioManager.stop()
 }
 
 // 5. Simple version (no visual indicator)
 .simpleSwipeBack()
 
 ───────────────────────────────────────────────────────────────
 
 🎯 REAL EXAMPLES FROM YOUR PROJECT:
 
 ───────────────────────────────────────────────────────────────
 */

// MARK: - Example 1: Story Detail View

struct StoryDetailViewExample: View {
    let story: Story
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Your beautiful background
            Rectangle()
                .fill(Color.blue.gradient)
                .ignoresSafeArea()
            
            VStack {
                // Back button (still works alongside swipe)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                
                // Your content
                Text(story.title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .swipeBack()  // ← Users can swipe OR tap button
    }
}

// MARK: - Example 2: Story Reading View (with audio)

struct StoryReadingViewExample: View {
    let story: Story
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            // Story content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(story.chapters) { chapter in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(chapter.title)
                                .font(.headline)
                            Text(chapter.content)
                        }
                    }
                }
                .padding()
            }
            
            // Audio player controls
            HStack {
                Button("Play") { isPlaying = true }
                Button("Pause") { isPlaying = false }
            }
        }
        .navigationBarHidden(true)
        .swipeBack {
            // IMPORTANT: Stop audio before going back!
            isPlaying = false
            // audioManager.stop() - Add your audio manager here
        }
    }
}

// MARK: - Example 3: Settings View (simple)

struct SettingsViewExample: View {
    var body: some View {
        Form {
            Section("Sound") {
                Toggle("Background Music", isOn: .constant(true))
            }
            
            Section("Appearance") {
                Toggle("Dark Mode", isOn: .constant(true))
            }
        }
        .navigationTitle("Settings")
        .swipeBack()  // Works great with forms!
    }
}

// MARK: - Example 4: Full-Screen Modal

struct FullScreenModalExample: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Full-screen content
            Image(systemName: "moon.stars.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
            
            // Close button
            VStack {
                HStack {
                    Button("Close") { dismiss() }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .swipeBack()  // Great for full-screen modals
    }
}

// MARK: - Pro Tips

/*
 
 💡 PRO TIPS:
 ────────────
 
 1️⃣ ALWAYS HIDE NAVIGATION BAR:
    .navigationBarHidden(true)
    
    Why? So the swipe gesture doesn't conflict with
    the system's default back gesture.
 
 
 2️⃣ CLEAN UP RESOURCES:
    .swipeBack {
        // yourAudioManager.stop()
        timer.invalidate()
    }
    
    Why? Prevent audio/timers from continuing after dismiss.
 
 
 3️⃣ ADJUST THRESHOLD FOR IMPORTANCE:
    
    • Light content: threshold: 100
    • Normal content: threshold: 120 (default)
    • Critical actions: threshold: 150
    
    Higher = harder to accidentally dismiss.
 
 
 4️⃣ COMBINE WITH BUTTON:
    Users should have BOTH options:
    • Visual back button for discovery
    • Swipe gesture for efficiency
 
 
 5️⃣ USE SIMPLE VERSION FOR MINIMAL UI:
    .simpleSwipeBack()
    
    When you want the gesture but not the visual indicator.
 
 
 ───────────────────────────────────────────────────────────────
 
 ⚠️ COMMON MISTAKES:
 
 ❌ DON'T: Forget to hide navigation bar
    → Gesture will conflict with system
 
 ❌ DON'T: Set threshold too high (>200)
    → Users won't discover the feature
 
 ❌ DON'T: Forget cleanup callbacks
    → Resources leak when dismissing
 
 ✅ DO: Test on actual device
    → Gestures feel different on hardware
 
 ✅ DO: Keep threshold 100-150 range
    → Sweet spot for usability
 
 ───────────────────────────────────────────────────────────────
 
 🎨 CUSTOMIZATION IDEAS:
 
 Want to customize the appearance?
 Edit SwipeBackModifier.swift:
 
 • Change "Back" text to icon only
 • Adjust animation spring values
 • Modify resistance curve
 • Add haptic feedback
 • Change indicator position
 
 ───────────────────────────────────────────────────────────────
 
 📊 PERFORMANCE:
 
 • Negligible CPU impact
 • No memory leaks
 • Smooth 60fps animations
 • Optimized for production use
 
 ───────────────────────────────────────────────────────────────
 
 🧪 TESTING CHECKLIST:
 
 □ Swipe from left edge
 □ Swipe from center
 □ Quick swipe (velocity)
 □ Slow swipe (threshold)
 □ Cancel swipe (release early)
 □ Works with scrolling content
 □ Resources cleaned up properly
 
 ───────────────────────────────────────────────────────────────
 
 📚 FILES IN THIS IMPLEMENTATION:
 
 • SwipeBackModifier.swift
   → The core modifier (copy this to any project!)
 
 • SwipeBackExamples.swift
   → Live examples you can run
 
 • SwipeBackQuickStart.swift (this file)
   → Documentation and quick reference
 
 ───────────────────────────────────────────────────────────────
 
 🚀 READY TO USE:
 
 Your StoryDetailView and StoryReadingView are already
 configured with swipe-back! Just build and test.
 
 Swipe right from anywhere on the screen to go back. 
 You'll see a smooth animation with a "Back" indicator.
 
 ═══════════════════════════════════════════════════════════════
 
 */

// MARK: - Minimal Copy-Paste Template

struct MinimalTemplateView: View {
    var body: some View {
        VStack {
            Text("Your content")
        }
        .navigationBarHidden(true)
        .swipeBack()
    }
}

// MARK: - Previews

#Preview("Story Detail") {
    NavigationStack {
        StoryDetailViewExample(story: Story.sampleStories[0])
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsViewExample()
    }
}

#Preview("Full Screen") {
    FullScreenModalExample()
}
