//
//  LanguageManager.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI
import Combine

enum AppLanguage: String, Codable {
    case english = "EN"
    case turkish = "TR"
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .turkish: return "🇹🇷"
        }
    }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }
}

class LanguageManager: ObservableObject {
    @Published var currentLanguage: AppLanguage {
        didSet {
            // Dil değiştiğinde UserDefaults'a kaydet
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            print("💾 Dil kaydedildi: \(currentLanguage.rawValue)")
        }
    }
    
    static let shared = LanguageManager()
    
    init() {
        // UserDefaults'tan kaydedilmiş dili yükle
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
            print("📱 Kaydedilmiş dil yüklendi: \(language.rawValue)")
        } else {
            // Varsayılan dil İngilizce
            self.currentLanguage = .english
            print("📱 Varsayılan dil ayarlandı: EN")
        }
    }
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .english ? .turkish : .english
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
}
