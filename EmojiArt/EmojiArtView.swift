//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI

struct EmojiArtView: View {
    @ObservedObject var viewModel: EmojiArtViewModel
    let testEmojis = "🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨🐯🦁🐮🐷🐸🐵"
    
    var body: some View {
        VStack(spacing: 0) {
            drawingBody
            palette
        }
    }
    
    var drawingBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay {
                    OptionalImage(uiImage: viewModel.backgroundImage)
                        .position(convertFromEmojiCoordinate((0, 0), in: geometry))
                }
                ForEach(viewModel.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: emojiSize(for: emoji)))
                        .position(emojiPosition(for: emoji, in: geometry))
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { provider, location in
                return emojiDrop(provider, at: location, in: geometry)
            }
        }
    }
    
    var palette: some View {
        ScrollEmojisView(emojis: testEmojis)
            .font(.system(size: ViewConstant.EmojiFontSize))
    }
    
    private func emojiDrop(_ provider: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = provider.loadObjects(ofType: URL.self) { url in
            viewModel.setBackground(.url(url))
        }
        
        if !found {
            found = provider.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    viewModel.setBackground(.imageData(data))
                }
            }
        }
        
        if !found {
            found = provider.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    viewModel.addEmoji(String(emoji), at: convertToEmojiCoordinate(at: location, in: geometry), size: ViewConstant.EmojiFontSize)
                }
            }
        }
        
        return found
    }
    
    private func convertToEmojiCoordinate(at location: CGPoint, in geometry: GeometryProxy) -> (Int, Int) {
        let frame = geometry.frame(in: .local)
        let center = frame.center
        let location = CGPoint(
            x: location.x -  center.x,
            y: location.y - center.y
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func emojiSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func emojiPosition(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinate((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinate(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let frame = geometry.frame(in: .local)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        return CGPoint (
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }
    
    struct ViewConstant {
        static let EmojiFontSize: CGFloat = 40
    }
}

struct ScrollEmojisView: View {
    let emojis: String
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map({ String($0) }), id: \.self ){ emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtView(viewModel: EmojiArtViewModel())
    }
}
