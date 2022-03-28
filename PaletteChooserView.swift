//
//  PaletteChooserView.swift
//  EmojiArt
//
//  Created by Entangled Mind on 26/3/2022.
//

import SwiftUI
import Combine

struct PaletteChooserView: View {
    let fontSize: CGFloat
    let testEmojis = "🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨🐯🦁🐮🐷🐸🐵"
    @EnvironmentObject var paletteStoreVM: PaletteStoreViewModel
    @State private var paletteIndex = 0
    @State private var isManaging = false
    @State private var editingPalette: Palette?
    
    var body: some View {
        let palette = paletteStoreVM.palette(at: paletteIndex)
        HStack {
            paletteButton
            HStack {
                Text(palette.name)
                ScrollEmojisView(emojis: palette.emojis)
            }
            .id(palette.id)
            .transition(rollUpTransition)
            .popover(item: $editingPalette) { palette in
                PaletteEditorView(palette: $paletteStoreVM.palettes[palette])
            }
            .sheet(isPresented: $isManaging) {
                PaletteManagerView()
            }
        }
        // using clipped() to make the rollUpTransition will not over its frame
        .clipped()
        .font(.system(size: fontSize))
    }
    
    var paletteButton: some View {
        Button {
            withAnimation {
                paletteIndex = (paletteIndex + 1) % paletteStoreVM.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
            editingPalette = paletteStoreVM.palette(at: paletteIndex)
        }
        AnimatedActionButton(title: "Add", systemImage: "plus") {
            paletteStoreVM.insertPalette(named: "new", emojis: "", at: paletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            paletteIndex = paletteStoreVM.removePalette(at: paletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            isManaging = true
        }
        Menu {
            ForEach(paletteStoreVM.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = paletteStoreVM.palettes.index(matching: palette) {
                        paletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert" )
        }
    }
    
    var rollUpTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: fontSize),
            removal: .offset(x: 0, y: -fontSize)
        )
    }
    
}

struct ScrollEmojisView: View {
    let emojis: String
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                // cannot use removingDupicateCharacter function of String
                ForEach(emojis.map({ String($0) }), id: \.self ) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}


struct PaletteChooserView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooserView(fontSize: EmojiArtView.ViewConstant.EmojiFontSize)
    }
}
