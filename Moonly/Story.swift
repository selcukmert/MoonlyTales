//
//  Story.swift
//  Moonly
//
//  Created by Mert Selçuk on 11.01.2026.
//

import SwiftUI

struct Story: Identifiable, Codable {
    let id: String
    let titleEn: String
    let titleTr: String?
    let iconName: String
    let readTime: Int // in minutes
    let author: String
    let backgroundImageName: String
    let cardImageName: String? // Kart görünümü için resim (örn: little_bunny.png)
    let pagesEn: [String]
    let pagesTr: [String]?
    var isFavorite: Bool = false
    var audioFileEn: String? // İngilizce ses dosyası
    var audioFileTr: String? // Türkçe ses dosyası
    
    // Computed properties for language-specific content
    func title(for language: AppLanguage) -> String {
        language == .turkish ? (titleTr ?? titleEn) : titleEn
    }
    
    func description(for language: AppLanguage) -> String {
        let pages = language == .turkish ? (pagesTr ?? pagesEn) : pagesEn
        return pages.first ?? ""
    }
    
    func fullDescription(for language: AppLanguage) -> String {
        let pages = language == .turkish ? (pagesTr ?? pagesEn) : pagesEn
        return pages.joined(separator: "\n\n")
    }
    
    func chapters(for language: AppLanguage) -> [Chapter] {
        let pages = language == .turkish ? (pagesTr ?? pagesEn) : pagesEn
        return pages.enumerated().map { index, content in
            let pageTitle = language == .turkish ? "Sayfa \(index + 1)" : "Page \(index + 1)"
            return Chapter(number: index + 1, title: pageTitle, content: content)
        }
    }
    
    // Dile göre ses dosyası döndür
    func audioFile(for language: AppLanguage) -> String? {
        let fileName = language == .turkish ? (audioFileTr ?? audioFileEn) : audioFileEn
        print("📢 Story: \(titleEn) | Dil: \(language) | Ses dosyası: \(fileName ?? "yok")")
        return fileName
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case titleEn = "title_en"
        case titleTr = "title_tr"
        case iconName
        case readTime
        case author
        case backgroundImageName
        case cardImageName = "card_image"
        case pagesEn = "pages_en"
        case pagesTr = "pages_tr"
        case isFavorite
        case audioFileEn = "audio_file_en"
        case audioFileTr = "audio_file_tr"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        titleEn = try container.decode(String.self, forKey: .titleEn)
        titleTr = try? container.decode(String.self, forKey: .titleTr)
        
        // JSON'dan pages array'lerini al
        pagesEn = try container.decode([String].self, forKey: .pagesEn)
        pagesTr = try? container.decode([String].self, forKey: .pagesTr)
        
        // Optional audio_file alanları
        audioFileEn = try? container.decode(String.self, forKey: .audioFileEn)
        audioFileTr = try? container.decode(String.self, forKey: .audioFileTr)
        
        // Optional card_image alanı
        cardImageName = try? container.decode(String.self, forKey: .cardImageName)
        
        // Varsayılan değerler (JSON'da olmayan alanlar için)
        iconName = "moon.stars.fill"
        readTime = max(5, pagesEn.count * 2) // Her sayfa ~2 dakika
        author = "Moonly"
        backgroundImageName = "moon_bg"
        isFavorite = false
    }
    
    // Normal initializer (sample data için)
    init(id: String = UUID().uuidString, 
         titleEn: String, 
         titleTr: String? = nil,
         iconName: String, 
         readTime: Int, 
         author: String, 
         backgroundImageName: String,
         cardImageName: String? = nil,
         pagesEn: [String],
         pagesTr: [String]? = nil,
         isFavorite: Bool = false, 
         audioFileEn: String? = nil,
         audioFileTr: String? = nil) {
        self.id = id
        self.titleEn = titleEn
        self.titleTr = titleTr
        self.iconName = iconName
        self.readTime = readTime
        self.author = author
        self.backgroundImageName = backgroundImageName
        self.cardImageName = cardImageName
        self.pagesEn = pagesEn
        self.pagesTr = pagesTr
        self.isFavorite = isFavorite
        self.audioFileEn = audioFileEn
        self.audioFileTr = audioFileTr
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
                titleEn: "The Cloud that Napped",
                titleTr: "Uyuklayan Bulut",
                iconName: "cloud.fill",
                readTime: 5,
                author: "Luna Sky",
                backgroundImageName: "cloud_bg",
                pagesEn: [
                    "High above the sleeping world, a small white cloud drifted lazily across the darkening sky. Unlike the other clouds who hurried along with the wind, this little cloud moved slowly, feeling drowsy and heavy...",
                    "As the stars began to twinkle, the cloud knew it was time to find a place to rest. Below, mountain peaks rose like gentle giants, their snowy tops glowing softly in the moonlight..."
                ],
                pagesTr: [
                    "Uyuyan dünyanın çok üstünde, küçük beyaz bir bulut kararırken gökyüzünde tembel tembel süzülüyordu. Rüzgarla birlikte acele eden diğer bulutların aksine, bu küçük bulut yavaş yavaş hareket ediyor, uykulu ve ağır hissediyordu...",
                    "Yıldızlar parlamaya başladığında, bulut dinlenecek bir yer bulma zamanının geldiğini biliyordu. Aşağıda, dağ zirveleri nazik devler gibi yükseliyordu, karlı tepeleri ay ışığında yumuşak bir şekilde parlıyordu..."
                ]
            ),
            Story(
                id: "fallback2",
                titleEn: "The Lighthouse Keeper",
                titleTr: "Deniz Feneri Bekçisi",
                iconName: "sun.and.horizon.fill",
                readTime: 12,
                author: "Marina West",
                backgroundImageName: "lighthouse_bg",
                pagesEn: [
                    "The lighthouse keeper climbed the spiral stairs slowly, each step echoing softly in the tower. Outside, the sea stretched endlessly, dark and calm under the emerging stars..."
                ],
                pagesTr: [
                    "Deniz feneri bekçisi spiral merdivenleri yavaşça çıkıyordu, her adım kulede yumuşak bir şekilde yankılanıyordu. Dışarıda, deniz sonsuzca uzanıyordu, ortaya çıkan yıldızların altında karanlık ve sakindi..."
                ]
            ),
        ]
    }
}
