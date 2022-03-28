//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Entangled Mind on 7/3/2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    // using @StateObject because it is the entrance point and source of truth, also we can easily to search all the source of truth by the property wrapper
    @StateObject var emojiViewModel = EmojiArtViewModel()
    @StateObject var paletteStoreVM = PaletteStoreViewModel(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtView(viewModel: emojiViewModel)
            // .environmentObject is going to inject the paletteStoreVM into EmojiArtView, and all subview of EmojiArtView can get this viewModel by subscribing @EnvironmentObject property wrapper
                .environmentObject(paletteStoreVM)
        }
    }
}
