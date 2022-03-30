//
//  EmojiArtViewModel.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI
import Combine

class EmojiArtViewModel: ObservableObject {
    @Published private(set) var model: EmojiArtModel {
        didSet {
            scheduleAutosave()
            if model.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    @Published var backgroundImage: UIImage?
    @Published var fetchStatus = FetchStatus.idle
    
    // emojis and background are just a shorthad for user,
    // so that user can viewModel.emojis instead of viewModel.model.emojis
    var emojis: [EmojiArtModel.Emoji] { model.emojis }
    var background: EmojiArtModel.Background { model.background }
    
    private var autosaveTimer: Timer?
    // the cancellable should be hold by view model, otherwise the subscriber inside a function call will be dismissed
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    enum FetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private struct Autosave {
        static let filename = "Autosave.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval: TimeInterval = 3.0
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            model = autosavedEmojiArt
            fetchBackgroundImageDataIfNecessary()
        } else {
            model = EmojiArtModel()
        }
     }
    
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
            // we don't use [weak self] because we want to have a strong reference self, so that the auto-save will be kept, and will not be released by ARC.
            self.autosave()
        }
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunc = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try model.json()
            print("\(thisFunc) json: \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("save success!")
        } catch let error where error is EncodingError {
            print("\(thisFunc) EncodingError: \(error.localizedDescription)")
        } catch {
            print("\(thisFunc) error: \(error)")
        }

    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        switch model.background {
        case .url(let url):
            fetchStatus = .fetching
            // To cancel any previous task (drag and drop background url), which wait for a long time for loading
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, respond) in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
//                // replaceError make publisher tranform to receiveValue only, without receiveCompletion
//                .replaceError(with: nil)
//
//                // assign can be only used when the piblisher without failure case and directly assign the value to somewhere
//            backgroundImageFetchCancellable = publisher
//                .assign(to: \EmojiArtViewModel.backgroundImage, on: self)
            
            backgroundImageFetchCancellable = publisher
                .sink(
                    receiveCompletion: { [weak self] result in
                        switch result {
                        case .finished:
                            print("Background image fetch successfully")
                            self?.fetchStatus = .idle
                        case .failure(let error):
                            print("Background image fetch fail: \n\(error.localizedDescription)")
                            self?.fetchStatus = .failed(url)
                        }
                    },
                    receiveValue: {  [weak self] image in
                        if let image = image {
                            self?.backgroundImage = image
                        } else {
                            self?.fetchStatus = .failed(url)
                        }
                    }
                )
            
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let data = try? Data(contentsOf: url) {
//                    DispatchQueue.main.async { [weak self] in
//                        self?.fetchStatus = .idle
//                        // To compare the existing background status, because user may drag and drop a new image after a long loading time.
//                        if self?.model.background == EmojiArtModel.Background.url(url) {
//                            self?.backgroundImage = UIImage(data: data)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.fetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
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
            model.emojis[index].size = Int(newSize.rounded(.toNearestOrAwayFromZero))
        }
    }
}
