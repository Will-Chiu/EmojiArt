//
//  EmojiArtViewModel.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI

class EmojiArtViewModel: ObservableObject {
    @Published private(set) var model: EmojiArtModel
    // emojis and background are just a shorthad for user,
    // so that user can viewModel.emojis instead of viewModel.model.emojis
    var emojis: [EmojiArtModel.Emoji] { model.emojis }
    var background: EmojiArtModel.Background { model.background }
    
    init() {
        model = EmojiArtModel()
        model.addEmoji("🔥", at: (-100, -100), size: 80)
        model.addEmoji("🌪", at: (100, 50), size: 40)
    }
    
    // MARK: - intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        model.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        model.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = model.emojis.index(matching: emoji) {
            model.emojis[index].x += Int(offset.width)
            model.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = model.emojis.index(matching: emoji) {
            let newSize = CGFloat(model.emojis[index].size) * scale
            model.emojis[index].size = Int(newSize.rounded(.awayFromZero))
        }
    }
}
