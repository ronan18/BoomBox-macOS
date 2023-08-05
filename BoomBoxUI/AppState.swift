//
//  AppState.swift
//  BoomBoxUI
//
//  Created by Ronan Furuta on 8/3/23.
//

import Foundation
import BoomBox
import AVKit
public class AppState: ObservableObject {
    @Published var packs: [String: BBPack] = [:]
    @Published var sounds: [String: BBSound] = [:]
    @Published var search: String = ""
    @Published var searchTags: [BBTag] = []
    @Published var allTags: [BBTag] = []
    @Published var suggestedTags: [BBTag] = []
    @Published var audioPlayer: AVAudioPlayer!
    @Published var selection: String? = nil
    @Published var displaySounds: [String] = []
    
    let core = BBCore()
    public init() {
        
    }
    public func loadPacks(_ url: URL) {
        self.core.loadPacks(url)
        self.packs = self.core.packs
        self.sounds = self.core.sounds
        self.allTags = self.core.tags.keys.map {tag in
            return BBTag(tag)
        }
    }
}
