//
//  PaletteManagerView.swift
//  EmojiArt
//
//  Created by Entangled Mind on 28/3/2022.
//

import SwiftUI

struct PaletteManagerView: View {
    @EnvironmentObject var paletteStoreVM: PaletteStoreViewModel
    // To get the environment parameter
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(paletteStoreVM.palettes) { palette in
                    NavigationLink(destination: PaletteEditorView(palette: $paletteStoreVM.palettes[palette])) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    paletteStoreVM.palettes.remove(atOffsets: indexSet)
                }
                .onMove { IndexSet, newOffset in
                    paletteStoreVM.palettes.move(fromOffsets: IndexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Palette Manager")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentationMode.wrappedValue.isPresented {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
        }
        // to over-write the device environment
        .environment(\.colorScheme, .dark)
        .font(.body)
    }
}

struct PaletteManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManagerView()
            .previewDevice("iPhone 8")
            .environmentObject(PaletteStoreViewModel(named: "preview"))
            .colorScheme(.dark)
    }
}
