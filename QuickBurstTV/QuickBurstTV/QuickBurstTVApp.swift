//
//  QuickBurstTVApp.swift
//  QuickBurstTV
//
//  Created by Kisura W.S.P on 2025-11-19.
//

import SwiftUI

@main
struct QuickBurstTVApp: App {

    @StateObject private var gameVM = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameVM)
        }
    }
}
