//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI

struct EmojiArtView: View {
    @ObservedObject var viewModel: EmojiArtViewModel
    @SceneStorage("EmojiArtView.finalZoomScale") private var finalZoomScale: CGFloat = 1
    // @GestureState to avoid frequently changing on finalZoomScale during pinch gesture, which will result exponential growth
    @GestureState private var gesturingZoomScale: CGFloat = 1
    private var zoomScale: CGFloat {
        finalZoomScale * gesturingZoomScale
    }
    @SceneStorage("EmojiArtView.finalPanOffset") private var finalPanOffset: CGSize = CGSize.zero
    // @GestureState to avoid frequently changing on finalPanOffset during pinch gesture, which will result exponential growth
    @GestureState private var gesturingPanOffset: CGSize = CGSize.zero
    private var panOffset: CGSize {
        (finalPanOffset + gesturingPanOffset) * zoomScale
    }
    @State private var alertToShow: IdentifiableAlert?
    @State private var autoZoomEnable = false
    @ScaledMetric var emojiFontSize: CGFloat = 40
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        VStack(spacing: 0) {
            drawingBody
            PaletteChooserView(fontSize: emojiFontSize)
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
                            // if below modifiers change position, emojis will have extra offset when drag or zoom
                            .scaleEffect(zoomScale)
                            .position(emojiPosition(for: emoji, in: geometry))
                    }
                }
            }
            .clipped()      // Don't oversize to other views
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { provider, location in
                return emojiDrop(provider, at: location, in: geometry)
            }
            .gesture(zoomGesture().simultaneously(with: panGesture()))
            .alert(item: $alertToShow) { alert in
                alert.alert()
            }
            .onChange(of: viewModel.fetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
            .onReceive(viewModel.$backgroundImage) { image in
                if autoZoomEnable {
                    zoomToFit(image, in: geometry.size)
                }
            }
            .toolbar {
                UndoButton(
                    undo: undoManager?.optionalUndoMenuItemTitle,
                    redo: undoManager?.optionalRedoMenuItemTitle
                )
            }
        }
    }
    
    private func emojiDrop(_ provider: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = provider.loadObjects(ofType: URL.self) { url in
            // convert url into imageURL, because url may be a redirect link or encoded linkage
            print("imageURL: \(url.imageURL)")
            // Only when a new background is dropped, auto zoom will be applicable
            autoZoomEnable = true
            viewModel.setBackground(.url(url.imageURL), undoManager: undoManager)
        }
        
        if !found {
            found = provider.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    viewModel.setBackground(.imageData(data), undoManager: undoManager)
                }
            }
        }
        
        if !found {
            found = provider.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    viewModel.addEmoji(String(emoji),
                                       at: convertToEmojiCoordinate(at: location, in: geometry),
                                       size: emojiFontSize / zoomScale, undoManager: undoManager)
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
        CGFloat(emoji.size)
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
            .updating($gesturingPanOffset) { lastestDragOffset, gesturingPanOffsetInOut, transaction in
                gesturingPanOffsetInOut = (lastestDragOffset.translation / zoomScale)
            }
            .onEnded { finalDrag in
                finalPanOffset = finalPanOffset + (finalDrag.translation / zoomScale)
            }
    }
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "Fetch Fail" + url.absoluteString) {
            Alert(
                title: Text("Background Image Fetch Failed"),
                message: Text(url.absoluteString),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtView(viewModel: EmojiArtViewModel())
    }
}
