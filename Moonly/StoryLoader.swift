//
//  StoryLoader.swift
//  Moonly
//
//  Created by AI Assistant on 21.01.2026.
//

import Foundation

/// JSON dosyasından hikayeleri yükleyen utility class
struct StoryLoader {
    
    /// JSON dosyasından hikayeleri yükler
    /// - Returns: Yüklenen hikayeler dizisi. Hata olursa sample stories döner.
    static func loadStories() -> [Story] {
        guard let url = Bundle.main.url(forResource: "bedtime_stories", withExtension: "json") else {
            print("❌ Error: bedtime_stories.json dosyası bulunamadı!")
            return Story.sampleStories
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // JSON yapısı: { "stories": [...] }
            let response = try decoder.decode(StoriesResponse.self, from: data)
            
            print("✅ Başarıyla \(response.stories.count) hikaye yüklendi!")
            return response.stories
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Decoding Error: Key '\(key.stringValue)' bulunamadı")
            print("Context: \(context.debugDescription)")
            print("Coding Path: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Decoding Error: Type mismatch - beklenen: \(type)")
            print("Context: \(context.debugDescription)")
            print("Coding Path: \(context.codingPath)")
        } catch let DecodingError.valueNotFound(type, context) {
            print("❌ Decoding Error: Value bulunamadı - tip: \(type)")
            print("Context: \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Decoding Error: Data bozuk")
            print("Context: \(context.debugDescription)")
        } catch {
            print("❌ JSON yükleme hatası: \(error.localizedDescription)")
        }
        
        // Hata durumunda sample stories döner
        return Story.sampleStories
    }
}

/// JSON root objesini temsil eden struct
private struct StoriesResponse: Codable {
    let stories: [Story]
}
