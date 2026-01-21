//
//  LanguageManager.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

enum AppLanguage: String {
    case english = "EN"
    case turkish = "TR"
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .turkish: return "🇹🇷"
        }
    }
    
    var name: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }
}

@Observable
class LanguageManager {
    var currentLanguage: AppLanguage = .english
    
    static let shared = LanguageManager()
    
    private init() {}
}
