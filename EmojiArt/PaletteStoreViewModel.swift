//
//  PaletteStoreViewModel.swift
//  EmojiArt
//
//  Created by Entangled Mind on 21/3/2022.
//

import SwiftUI

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    var id: Int
    
    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}

class PaletteStoreViewModel: ObservableObject {
    let name: String
    @Published var palettes: [Palette] = Array() {
        didSet {
            storeToUserDefault()
        }
    }
    private var userDefaultKey: String {
        "PaletteStore." + name
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefault()
        if palettes.isEmpty {
            print("using built-in default palettes")
            insertPalette(named: "Animals", emojis: "🐅🐆🦓🦍🦧🦣🐘🦛🦏🐪🐫🦒🦘🦬🐃🐂🐄🐎🐖🐏🐑🦙🐐🦌🐕🐩")
            insertPalette(named: "Insects", emojis: "🐝🪱🐛🦋🐌🐞🐜🪰🪲🪳🦟🦗🕷🦂")
            insertPalette(named: "Fishs", emojis: "🐙🦑🦐🦞🦀🐡🐠🐟🐬🐳🐋🦈")
            insertPalette(named: "Hearts", emojis: "❤️🧡💛💚💙💜🖤🤍🤎💔❤️‍🔥❤️‍🩹❣️💕💞💓💗💖💘💝")
            insertPalette(named: "Fruits", emojis: "🍏🍎🍐🍊🍋🍌🍉🍇🍓🫐🍈🍒🍑🥭🍍")
            insertPalette(named: "Numbers", emojis: "0️⃣1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣")
        } else {
            print("restore palettes successfully: \(palettes)")
        }
    }
    
    private func storeToUserDefault() {
//        // Map palettes into [[String]], because [Palette] is NOT property list object
//        UserDefaults.standard.set(palettes.map{ [$0.name, $0.emojis, $0.id] }, forKey: userDefaultKey)
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultKey)
    }
    
    private func restoreFromUserDefault() {
//        // Since the location of [[String]] is fragile, using JSONDecoder will be more nice for presistency
//        if let propertyLitPalette = UserDefaults.standard.array(forKey: userDefaultKey) as? [[String]] {
//            for paletteArray in propertyLitPalette {
//                if paletteArray.count == 3, let id = Int(paletteArray[2]), palettes.contains(where: { $0.id == id }) {
//                    let palette = Palette(name: paletteArray[0], emojis: paletteArray[1], id: id)
//                    palettes.append(palette)
//                }
//            }
//        }
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultKey),
           let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
            palettes = decodedPalettes
        }
    }
    
    // MARK: - Intent
    
    func palette(at index: Int) -> Palette {
        let safeindex = min(max(index, 0), palettes.count - 1)
        return palettes[safeindex]
    }
    
    @discardableResult  // discardableResult is to ignore the compiler complaint for those unused variable
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let uniqueID = (palettes.max(by: {$0.id < $1.id})?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: uniqueID)
        let safeindex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeindex)
    }
    
}
