//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let emojiViewModel = EmojiArtViewModel()
    var body: some Scene {
        WindowGroup {
            EmojiArtView(viewModel: emojiViewModel)
        }
    }
}
