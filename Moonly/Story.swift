//
//  Story.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct Story: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let readTime: Int // in minutes
    let author: String
    let fullDescription: String
    let backgroundImageName: String
    let chapters: [Chapter]
    var isFavorite: Bool = false
}

struct Chapter: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let content: String
}

// Sample data
extension Story {
    static let sampleStories: [Story] = [
        Story(
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
        Story(
            title: "Whispers of the Forest",
            description: "Soft sounds of the night woods, where the leaves rustle gentle lullabies to the...",
            iconName: "tree.fill",
            readTime: 8,
            author: "Forest Moon",
            fullDescription: "Soft sounds of the night woods, where the leaves rustle gentle lullabies to the sleeping creatures. Let the forest's whispers guide you to sleep.",
            backgroundImageName: "forest_bg",
            chapters: [
                Chapter(number: 1, title: "The Silent Forest", content: "The wind whispered through the ancient pines, carrying secrets of the old world that only the mountains could remember. Soft moss carpeted the forest floor, damp and cool against the earth, creating a path that seemed to swallow sound itself..."),
            ]
        ),
        Story(
            title: "Raindrops on the Roof",
            description: "The calming rhythm of a gentle shower washing away the day's worries.",
            iconName: "drop.fill",
            readTime: 15,
            author: "Storm Whisper",
            fullDescription: "The calming rhythm of a gentle shower washing away the day's worries. Close your eyes and let the rain sing you to sleep.",
            backgroundImageName: "rain_bg",
            chapters: [
                Chapter(number: 1, title: "The First Drop", content: "A single raindrop fell from the darkening sky, landing softly on the old tin roof with a gentle ping. Then another. And another. Soon, a symphony of rain began..."),
            ]
        ),
    ]
}
