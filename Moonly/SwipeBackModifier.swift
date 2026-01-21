//
//  SwipeBackModifier.swift
//  Moonly
//
//  Created by Mert Selçuk on 21.01.2026.
//

import SwiftUI

// MARK: - Swipe Back Modifier

/// A reusable ViewModifier that adds swipe-back gesture with visual feedback
struct SwipeBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    let threshold: CGFloat // Distance needed to trigger dismiss
    let onDismiss: (() -> Void)? // Optional callback before dismissing
    
    init(threshold: CGFloat = 120, onDismiss: (() -> Void)? = nil) {
        self.threshold = threshold
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            // Back indicator (appears during swipe)
            if isDragging && dragOffset > 30 {
                backIndicator
                    .opacity(swipeProgress)
                    .transition(.opacity)
            }
            
            // Main content
            content
                .offset(x: dragOffset)
                .gesture(swipeGesture)
        }
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: dragOffset)
    }
    
    // MARK: - Swipe Gesture
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Only allow right swipe (positive translation)
                if value.translation.width > 0 {
                    isDragging = true
                    // Apply resistance for smoother feel
                    dragOffset = sqrt(value.translation.width) * 15
                }
            }
            .onEnded { value in
                isDragging = false
                
                let velocity = value.predictedEndTranslation.width
                let shouldDismiss = value.translation.width > threshold || velocity > 250
                
                if shouldDismiss {
                    // Call optional callback
                    onDismiss?()
                    
                    // Animate out and dismiss
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        dragOffset = UIScreen.main.bounds.width
                    }
                    
                    // Dismiss after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        dismiss()
                    }
                } else {
                    // Animate back to original position
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    // MARK: - Visual Indicator
    
    private var backIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Back")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.leading, 30)
        .frame(maxHeight: .infinity, alignment: .leading)
    }
    
    // MARK: - Computed Properties
    
    /// Progress from 0 to 1 based on swipe distance
    private var swipeProgress: Double {
        min(Double(dragOffset) / Double(threshold), 1.0)
    }
}

// MARK: - View Extension

extension View {
    /// Add swipe-back gesture to any view
    /// - Parameters:
    ///   - threshold: Distance in points needed to trigger dismiss (default: 120)
    ///   - onDismiss: Optional callback executed before dismissing
    func swipeBack(threshold: CGFloat = 120, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(SwipeBackModifier(threshold: threshold, onDismiss: onDismiss))
    }
}

// MARK: - Simple Swipe Back (No Visual Feedback)

/// A minimal swipe back modifier without visual indicators
struct SimpleSwipeBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGFloat = 0
    
    let threshold: CGFloat
    let onDismiss: (() -> Void)?
    
    init(threshold: CGFloat = 100, onDismiss: (() -> Void)? = nil) {
        self.threshold = threshold
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width > 0 {
                            dragOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if value.translation.width > threshold || value.predictedEndTranslation.width > 200 {
                            onDismiss?()
                            dismiss()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: dragOffset)
    }
}

extension View {
    /// Add simple swipe-back gesture (no visual indicator)
    func simpleSwipeBack(threshold: CGFloat = 100, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(SimpleSwipeBackModifier(threshold: threshold, onDismiss: onDismiss))
    }
}

// MARK: - Usage Examples

/*
 
 🎯 BASIC USAGE:
 ───────────────
 
 struct MyView: View {
     @Environment(\.dismiss) private var dismiss
     
     var body: some View {
         VStack {
             Text("Swipe right to go back")
         }
         .swipeBack()  // ← Add swipe back with visual indicator
     }
 }
 
 
 🎯 WITH CUSTOM THRESHOLD:
 ─────────────────────────
 
 struct MyView: View {
     var body: some View {
         VStack {
             Text("Content")
         }
         .swipeBack(threshold: 150)  // Requires more distance to dismiss
     }
 }
 
 
 🎯 WITH DISMISS CALLBACK:
 ─────────────────────────
 
 struct StoryView: View {
     @StateObject var audioManager = AudioManager()
     
     var body: some View {
         VStack {
             Text("Story content")
         }
         .swipeBack {
             // Stop audio before going back
             audioManager.stop()
         }
     }
 }
 
 
 🎯 SIMPLE VERSION (NO VISUAL INDICATOR):
 ────────────────────────────────────────
 
 struct MyView: View {
     var body: some View {
         VStack {
             Text("Content")
         }
         .simpleSwipeBack()  // Just the gesture, no indicator
     }
 }
 
 
 ✨ FEATURES:
 ────────────
 
 ✅ Smooth spring animations
 ✅ Visual "Back" indicator during swipe
 ✅ Velocity detection for quick swipes
 ✅ Resistance curve for natural feel
 ✅ Optional dismiss callback
 ✅ Customizable threshold
 ✅ Works with NavigationStack
 ✅ Clean reusable code
 
 */
