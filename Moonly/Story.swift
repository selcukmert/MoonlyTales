//
//  Story.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct Story: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let readTime: Int // in minutes
    let author: String
    let fullDescription: String
    let backgroundImageName: String
    let chapters: [Chapter]
    var isFavorite: Bool = false
    var audioFile: String? // JSON'daki audio_file alanı için
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "title_en"
        case description
        case iconName
        case readTime
        case author
        case fullDescription
        case backgroundImageName
        case chapters = "pages_en"
        case isFavorite
        case audioFile = "audio_file"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        
        // JSON'dan pages_en array'ini alıp birleştiriyoruz
        let pages = try container.decode([String].self, forKey: .chapters)
        fullDescription = pages.joined(separator: "\n\n")
        
        // Optional audio_file alanı
        audioFile = try? container.decode(String.self, forKey: .audioFile)
        
        // Varsayılan değerler (JSON'da olmayan alanlar için)
        description = pages.first ?? ""
        iconName = "moon.stars.fill"
        readTime = max(5, pages.count * 2) // Her sayfa ~2 dakika
        author = "Moonly"
        backgroundImageName = "moon_bg"
        isFavorite = false
        
        // Chapters oluştur
        chapters = pages.enumerated().map { index, content in
            Chapter(number: index + 1, title: "Page \(index + 1)", content: content)
        }
    }
    
    // Normal initializer (sample data için)
    init(id: String = UUID().uuidString, title: String, description: String, iconName: String, readTime: Int, author: String, fullDescription: String, backgroundImageName: String, chapters: [Chapter], isFavorite: Bool = false, audioFile: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.readTime = readTime
        self.author = author
        self.fullDescription = fullDescription
        self.backgroundImageName = backgroundImageName
        self.chapters = chapters
        self.isFavorite = isFavorite
        self.audioFile = audioFile
    }
}

struct Chapter: Identifiable, Codable {
    let id: String
    let number: Int
    let title: String
    let content: String
    
    init(id: String = UUID().uuidString, number: Int, title: String, content: String) {
        self.id = id
        self.number = number
        self.title = title
        self.content = content
    }
}

// Sample data - JSON'dan yüklenir, fallback olarak kullanılır
extension Story {
    static var sampleStories: [Story] {
        // Önce JSON'dan yüklemeyi dene
        let loadedStories = StoryLoader.loadStories()
        
        // Eğer JSON'dan hikaye yüklendiyse onları kullan
        if !loadedStories.isEmpty && loadedStories.first?.id != "fallback" {
            return loadedStories
        }
        
        // JSON yüklenemezse fallback hikayeler
        return [
            Story(
                id: "fallback",
                title: "The Cloud that Napped",
                description: "A gentle journey through the sky as a little cloud looks for the perfect mountain peak...",
                iconName: "cloud.fill",
                readTime: 5,
                author: "Luna Sky",
                fullDescription: "A gentle journey through the sky as a little cloud looks for the perfect mountain peak to rest upon. Drift along with our sleepy cloud friend.",
                backgroundImageName: "cloud_bg",
                chapters: [
                    Chapter(number: 1, title: "The Floating Dream", content: "High above the sleeping world, a small white cloud drifted lazily across the darkening sky. Unlike the other clouds who hurried along with the wind, this little cloud moved slowly, feeling drowsy and heavy..."),
                    Chapter(number: 2, title: "The Mountain Search", content: "As the stars began to twinkle, the cloud knew it was time to find a place to rest. Below, mountain peaks rose like gentle giants, their snowy tops glowing softly in the moonlight..."),
                ]
            ),
            Story(
                id: "fallback2",
                title: "The Lighthouse Keeper",
                description: "Watching the rhythmic waves roll in under the starlight, guiding ships safely to the...",
                iconName: "sun.and.horizon.fill",
                readTime: 12,
                author: "Marina West",
                fullDescription: "Watching the rhythmic waves roll in under the starlight, guiding ships safely to the harbor. A peaceful tale of dedication and tranquility.",
                backgroundImageName: "lighthouse_bg",
                chapters: [
                    Chapter(number: 1, title: "The Evening Watch", content: "The lighthouse keeper climbed the spiral stairs slowly, each step echoing softly in the tower. Outside, the sea stretched endlessly, dark and calm under the emerging stars..."),
                ]
            ),
        ]
    }
}
