//
//  ContentView.swift
//  BoomBoxUI
//
//  Created by Ronan Furuta on 8/3/23.
//

import SwiftUI
import AVKit
import BoomBox


struct ContentView: View {
    @ObservedObject var appState: AppState
   
   
    @State var searching = false
    @State var requestPermission = false
   
   
    var body: some View {
        HStack {
           
            SoundFullView(appState: appState)
            SoundTableView(appState: appState)
           
                       
        }.onChange(of: self.appState.selection, perform: {selection in
                        if (self.appState.audioPlayer != nil) {
                            self.appState.audioPlayer.stop()
                            
                        }
                        guard !(selection?.isEmpty ?? true) else {
                            print("no selection")
                            return
                        }
                        guard let sound = self.appState.sounds[selection!] else {
                            print("selected sound doesn't exist")
                            return
                        }
                        print("playing", sound.title)
                        self.appState.audioPlayer = try! AVAudioPlayer(contentsOf: sound.url)
                        self.appState.audioPlayer.play()
                        
                    }).onAppear {
                        self.appState.displaySounds = Array(self.appState.sounds.keys)
                    }.task {
                        await self.loadData()
                    }
                    .fileImporter(isPresented: $requestPermission, allowedContentTypes: [.directory], onCompletion: {file in
                        do {
                            let url = try file.get()
                            UserDefaults.standard.set(url, forKey: "url")
                            self.appState.loadPacks(url)
                            self.appState.displaySounds = Array(self.appState.sounds.keys)
                        } catch {
                            print(error)
                        }
                    }).onSubmit(of: .search) {
                        self.searching = true
                        
                        Task {
                            self.appState.displaySounds = await self.appState.core.search(self.appState.search, self.appState.searchTags)
                        }
                        self.searching = false
                    }.onChange(of: self.appState.search, perform: {search in
                        Task {
                            self.appState.suggestedTags = self.appState.allTags.filter({item in
                                item.id.contains(search)
                            })
                        }
                    }).onChange(of: self.appState.searchTags.count, perform: { tags in
                        self.searching = true
                        Task {
                            self.appState.displaySounds = await self.appState.core.search(self.appState.search, self.appState.searchTags)
                        }
                        self.searching = false
                    })
                
            
        
    }
    func loadData() async {
        if let url = UserDefaults.standard.url(forKey: "url") {
             do {
                 
                print("getting data fot path", url)
                let data = try FileManager.default.contentsOfDirectory(atPath: url.path)
                 print(data)
                 if (data.contains("db")) {
                     self.appState.loadPacks(url)
                     self.appState.displaySounds = Array(self.appState.sounds.keys)
                 } else {
                     self.requestPermission = true
                 }
                
             } catch {
                 print("fetch error", error)
             }
         } else {
             self.requestPermission = true
         }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appState: AppState())
    }
}
