//
//  EmojiArtViewModel.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI

class EmojiArtViewModel: ObservableObject {
    @Published private(set) var model: EmojiArtModel {
        didSet {
            if model.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    // emojis and background are just a shorthad for user,
    // so that user can viewModel.emojis instead of viewModel.model.emojis
    var emojis: [EmojiArtModel.Emoji] { model.emojis }
    var background: EmojiArtModel.Background { model.background }
    @Published var backgroundImage: UIImage?
    
    init() {
        model = EmojiArtModel()
        model.addEmoji("🔥", at: (-100, -100), size: 80)
        model.addEmoji("🌪", at: (100, 50), size: 40)
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        switch model.background {
        case .url(let url):
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        // To compare the existing background status, because user may drag and drop a new image after a long loading time.
                        if self?.model.background == EmojiArtModel.Background.url(url) {
                            self?.backgroundImage = UIImage(data: data)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case.blank:
            break
        }
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
