//
//  SoundTableView.swift
//  BoomBoxUI
//
//  Created by Ronan Furuta on 8/5/23.
//

import SwiftUI

struct SoundTableView: View {
    @ObservedObject var appState: AppState
    var body: some View {
        Table(self.appState.displaySounds.map({id in
                        return self.appState.sounds[id]!
                    }), selection: self.$appState.selection) {
                        TableColumn("Name") { sound in
                            Text(sound.title)
                            
                            
                        }
                        TableColumn("duration") {sound in
                            Text(sound.duration.timeCodeLength())
                        }.width(75)
                        TableColumn("tags") { sound in
                            
                            Text(sound.tags.joined(separator: ", "))
                            
                            
                        }
                        
                    }.searchable(text: self.$appState.search, tokens: self.$appState.searchTags, suggestedTokens: self.$appState.suggestedTags) {token in
                        Text(token.id)
                    }
    }
}

struct SoundTableView_Previews: PreviewProvider {
    static var previews: some View {
        SoundTableView(appState: AppState())
    }
}
