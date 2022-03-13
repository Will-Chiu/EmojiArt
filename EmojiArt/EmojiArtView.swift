//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI

struct EmojiArtView: View {
    @ObservedObject var viewModel: EmojiArtViewModel
    @State private var finalZoomScale: CGFloat = 1
    // @GestureState to avoid frequently changing on finalZoomScale during pinch gesture, which will result exponential growth
    @GestureState private var gesturingZoomScale: CGFloat = 1
    private var zoomScale: CGFloat {
        finalZoomScale * gesturingZoomScale
    }
    
    @State private var finalPanOffset: CGSize = CGSize.zero
    // @GestureState to avoid frequently changing on finalPanOffset during pinch gesture, which will result exponential growth
    @GestureState private var gesturingPanOffset: CGSize = CGSize.zero
    private var panOffset: CGSize {
        (finalPanOffset + gesturingPanOffset)
    }
    
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
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinate((0, 0), in: geometry))
                }
                .gesture(doubleTapToZoom(in: geometry.size))
                if viewModel.fetchStatus == .fetching {
                    ProgressView().scaleEffect(3)
                } else {
                    ForEach(viewModel.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: emojiSize(for: emoji)))
                            .position(emojiPosition(for: emoji, in: geometry))
                            .scaleEffect(zoomScale)
                    }
                }
            }
            .clipped()      // Don't oversize to other views
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { provider, location in
                return emojiDrop(provider, at: location, in: geometry)
            }
            .gesture(zoomGesture().simultaneously(with: panGesture()))
        }
    }
    
    var palette: some View {
        ScrollEmojisView(emojis: testEmojis)
            .font(.system(size: ViewConstant.EmojiFontSize))
    }
    
    private func emojiDrop(_ provider: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = provider.loadObjects(ofType: URL.self) { url in
            // convert url into imageURL, because url may be a redirect link or encoded linkage
            print("imageURL: \(url.imageURL)")
            viewModel.setBackground(.url(url.imageURL))
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
                    viewModel.addEmoji(String(emoji),
                                       at: convertToEmojiCoordinate(at: location, in: geometry),
                                       size: ViewConstant.EmojiFontSize / zoomScale)
                }
            }
        }
        
        return found
    }
    
    private func convertToEmojiCoordinate(at location: CGPoint, in geometry: GeometryProxy) -> (Int, Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func emojiSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size) * zoomScale
    }
    
    private func emojiPosition(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinate((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinate(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint (
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoomScale = size.width / image.size.width
            let vZoomScale = size.height / image.size.height
            finalPanOffset = .zero
            finalZoomScale = min(hZoomScale, vZoomScale)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(viewModel.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gesturingZoomScale) { lastestGesture, gesturingZoomScaleInOut,transaction in
                gesturingZoomScaleInOut = lastestGesture
            }
            .onEnded { gestureScaleAtEnd in
                finalZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturingPanOffset) { finalDragOffset, gesturingPanOffsetInOut, transaction in
                gesturingPanOffsetInOut = (finalDragOffset.translation / zoomScale)
            }
            .onEnded { finalDrag in
                finalPanOffset = finalPanOffset + (finalDrag.translation / zoomScale)
            }
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
