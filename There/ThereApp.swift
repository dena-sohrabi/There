//
//  ThereApp.swift
//  There
//
//  Created by Dena Sohrabi on 9/2/24.
//

import AppKit
import MenuBarExtraAccess
import SwiftUI

@main
struct ThereApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    @ObservedObject var appState = AppState.shared

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(\.database, .shared)
                .frame(width: 350)
                .frame(width: 350)
                .frame(minHeight: 200)
                .frame(maxHeight: 400)
                .padding(.top)
                .overlay(alignment: .topTrailing) {
                    Button("Open in new Window") {
                        openWindow(id: "app")
                    }
                    .padding(4)
                }
        } label: {
            Image(systemName: "clock")
                .onAppear {
                    if UserDefaults.standard.bool(forKey: "hasCompletedInitialSetup") == false {
                        openWindow(id: "init")
                    } else {
                        appState.presentMenu()
                    }
                }
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $appState.menuBarViewIsPresented)
        .windowResizability(.contentSize)

        Window("There", id: "app") {
            ContentView()
                .environment(\.database, .shared)
                .frame(width: 350)
                .frame(minHeight: 200)
                .frame(maxHeight: 400)
                .background(TransparentBackgroundView().ignoresSafeArea())
        }
        .windowStyle(.hiddenTitleBar)
        .defaultPosition(.topLeading)
        .windowResizability(.contentSize)

        Window("init", id: "init") {
            InitialView()
                .environment(\.database, .shared)
                .fixedSize()
                .frame(width: 600, height: 400)
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 600, height: 400)
        .defaultPosition(.center)
        .windowResizability(.contentSize)
        #if MAC_OS_VERSION_15_0
            .windowBackgroundDragBehavior(.enabled)
        #endif

        Window("Add Timezone", id: "add-timezone") {
            AddTimezone()
                .environment(\.database, .shared)
                .frame(width: 500, height: 400)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 400, height: 400)
        .defaultPosition(.center)
        .windowResizability(.contentSize)
        #if MAC_OS_VERSION_15_0
            .windowBackgroundDragBehavior(.enabled)
        #endif

        Settings {
            Text("Coming soon...")
        }
        #if MAC_OS_VERSION_15_0
            .windowStyle(.plain)
        #endif
            .defaultSize(width: 600, height: 400)
            .windowResizability(.automatic)
    }
}

extension EnvironmentValues {
    @Entry var database: AppDatabase = .shared
}

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var menuBarViewIsPresented: Bool = false
    func presentMenu() {
//        menuBarViewIsPresented = true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//            AppState.shared.menuBarViewIsPresented = true
//        }
    }
}
