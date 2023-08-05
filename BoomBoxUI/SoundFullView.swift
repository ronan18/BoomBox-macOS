//
//  SoundFullView.swift
//  BoomBoxUI
//
//  Created by Ronan Furuta on 8/5/23.
//

import SwiftUI
import BoomBox
import DSWaveformImageViews

struct SoundFullView: View {
    @ObservedObject var appState: AppState
    var body: some View {
        
        VStack {
            if (self.appState.selection != nil) {
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading) {
                        Image(nsImage: NSImage(contentsOf: self.appState.packs[self.appState.sounds[self.appState.selection!]!.packId]!.imageURL)!).resizable().scaledToFit()
                        Text(self.appState.sounds[self.appState.selection!]?.title ?? "no").font(.headline).bold().foregroundColor(.white).padding([.horizontal], 6).padding(.bottom, 12).padding(.top, 3)
                    }.background(Color("DarkBackground")).cornerRadius(12).onDrag {
                        let data = self.appState.sounds[self.appState.selection!]!.url
                        return NSItemProvider(contentsOf: data)!
                    }.shadow(color: Color("Shadow"), radius: 6)
                    
                    Divider()
                    VStack {
                        WrappingHStack(id: \.self ) {
                            ForEach(self.appState.sounds[self.appState.selection!]!.tags, id: \.self) {tag in
                                Button(action: {
                                    let index = self.appState.searchTags.firstIndex(where: {item in
                                        item.id == tag
                                    })
                                    if let index = index {
                                        self.appState.searchTags.remove(at: index)
                                    } else {
                                        self.appState.searchTags.append(BBTag(tag))
                                    }
                                }) {
                                    Text(tag)
                                }.padding(2).tint(Color.primary)
                            }
                        }
                        
                        
                        Spacer()
                        WaveformView(audioURL: self.appState.sounds[self.appState.selection!]!.url, configuration: .init(style: .filled(.white))).frame(height: 100).padding()
                        
                        
                    }
                }
            } else {
                Text("No Selection")
                
            }
        }.padding().frame(width: 300)
    }
}

struct SoundFullView_Previews: PreviewProvider {
    static var previews: some View {
        SoundFullView(appState: AppState())
    }
}
