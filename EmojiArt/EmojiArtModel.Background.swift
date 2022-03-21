//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import Foundation

extension EmojiArtModel {
    enum Background: Equatable, Codable {
        case blank
        case url(URL)
        case imageData(Data)
        
        enum BackgroundCodingKeys: String, CodingKey {
            case url = "URL"
            case imageData
        }
        
        // since Swift 5.5, enum with associated value can be auto-synthesizing serialization
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: BackgroundCodingKeys.self)
            // if-let-try? will return nil and pass to next if the decode fail
            if let url = try? container.decode(URL.self, forKey: .url) {
                self = .url(url)
            } else if let data = try? container.decode(Data.self, forKey: .imageData) {
                self = .imageData(data)
            } else {
                self = .blank
            }
        }
        // since Swift 5.5, enum with associated value can be auto-synthesizing serialization
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: BackgroundCodingKeys.self)
            switch self {
            case .url(let url): try container.encode(url, forKey: .url)
            case .imageData(let data): try container.encode(data, forKey: .imageData)
            case .blank: break
            }
        }
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
