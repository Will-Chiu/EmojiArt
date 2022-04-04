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
        // In iPad, user can drag and drop 2 same app onto the screen. And the 2 app will share above @StateObject in the same time, which means one of the app change the viewModel, another one have same result/effect.
        WindowGroup {
            EmojiArtView(viewModel: emojiViewModel)
            // .environmentObject is going to inject the paletteStoreVM into EmojiArtView, and all subview of EmojiArtView can get this viewModel by subscribing @EnvironmentObject property wrapper
                .environmentObject(paletteStoreVM)
        }
    }
}
