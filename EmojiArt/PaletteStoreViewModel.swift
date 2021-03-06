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
            insertPalette(named: "Animals", emojis: "๐๐๐ฆ๐ฆ๐ฆง๐ฆฃ๐๐ฆ๐ฆ๐ช๐ซ๐ฆ๐ฆ๐ฆฌ๐๐๐๐๐๐๐๐ฆ๐๐ฆ๐๐ฉ")
            insertPalette(named: "Insects", emojis: "๐๐ชฑ๐๐ฆ๐๐๐๐ชฐ๐ชฒ๐ชณ๐ฆ๐ฆ๐ท๐ฆ")
            insertPalette(named: "Fishs", emojis: "๐๐ฆ๐ฆ๐ฆ๐ฆ๐ก๐ ๐๐ฌ๐ณ๐๐ฆ")
            insertPalette(named: "Hearts", emojis: "โค๏ธ๐งก๐๐๐๐๐ค๐ค๐ค๐โค๏ธโ๐ฅโค๏ธโ๐ฉนโฃ๏ธ๐๐๐๐๐๐๐")
            insertPalette(named: "Fruits", emojis: "๐๐๐๐๐๐๐๐๐๐ซ๐๐๐๐ฅญ๐")
            insertPalette(named: "Numbers", emojis: "0๏ธโฃ1๏ธโฃ2๏ธโฃ3๏ธโฃ4๏ธโฃ5๏ธโฃ6๏ธโฃ7๏ธโฃ8๏ธโฃ9๏ธโฃ")
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
