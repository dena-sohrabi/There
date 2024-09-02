//
//  ThereApp.swift
//  There
//
//  Created by Dena Sohrabi on 9/2/24.
//

import SwiftUI

@main
struct ThereApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image(systemName: "clock")
        }
        .menuBarExtraStyle(.window)
        
    }
}
