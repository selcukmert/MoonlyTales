//
//  MoonlyApp.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

@main
struct MoonlyApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(languageManager)
        }
    }
}
