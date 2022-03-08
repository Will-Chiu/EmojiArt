//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import Foundation
import SwiftUI

struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    private var uniqueEmojiId = 0
    
    // Empty init prevent someone can create Emoji by creating instance of EmojiArtModel
    init() {}
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, x: location.x, y: location.y, size: size))
    }
    
    // Since we may put Emoji into Set, so it will be convenient to be Hashable
    // As the stored properties are all hashable, so there is no addititon compliance need
    struct Emoji: Identifiable, Hashable {
        let id: Int
        let text: String
        // Since model is out of any UI framework, we use Int instead of CGFloat or etc
        // x, y are offset from View center
        var x: Int
        var y: Int
        var size: Int
        
        // fileprivate prevent creating a new instance from other part of codes
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
}
