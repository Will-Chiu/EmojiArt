//
//  PaletteEditorView.swift
//  EmojiArt
//
//  Created by Entangled Mind on 27/3/2022.
//

import SwiftUI

struct PaletteEditorView: View {
    @Binding var palette: Palette
    @State private var emojiToAdd: String = ""
    
    var body: some View {
        // Form style
        Form {
            nameSection
            addEmojiSection
            removeEmojiSection
        }
        .navigationTitle("Edit " + palette.name)
        .font(.system(size: 20))
        .frame(minWidth: 300, minHeight: 400)
    }
    
    var nameSection: some View {
        Section {
            TextField("Name", text: $palette.name)
        } header: {
            Text("Name")
        }
    }
    
    var addEmojiSection: some View {
        Section {
            TextField("Emoji", text: $emojiToAdd)
        } header: {
            Text("Add Emoji")
        }
        .onChange(of: emojiToAdd) { emoji in
            addEmojiToPalette(emoji)
        }
    }
    
    var removeEmojiSection: some View {
        Section {
            let emojis = palette.emojis.removeDuplicate().map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
        } header: {
            Text("Remove Emoji")
        }
    }
    
    func addEmojiToPalette(_ emoji: String) {
        withAnimation {
            palette.emojis = (emoji + palette.emojis)
                .filter { $0.isEmoji }
                .removeDuplicate()
        }
    }

}

struct PaletteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        // .constant binding a value for preview
        PaletteEditorView(palette: .constant(PaletteStoreViewModel(named: "preview").palette(at: 2)))
            .previewLayout(.fixed(width: 300.0, height: 350.0))
        PaletteEditorView(palette: .constant(PaletteStoreViewModel(named: "preview").palette(at: 3)))
            .previewLayout(.fixed(width: 300.0, height: 600.0))
    }
}
