//
//  BoomBoxUIApp.swift
//  BoomBoxUI
//
//  Created by Ronan Furuta on 8/3/23.
//

import SwiftUI

@main
struct BoomBoxUIApp: App {
    @State var appState = AppState()
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
    }
}
