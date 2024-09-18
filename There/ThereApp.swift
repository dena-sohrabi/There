//
//  ThereApp.swift
//  There
//
//  Created by Dena Sohrabi on 9/2/24.
//

import AppKit
import MenuBarExtraAccess
import PostHog
import SwiftUI
import UserNotifications

@main
struct ThereApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    @ObservedObject var appState = AppState.shared
    @StateObject var router: Router = Router()
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environment(\.database, .shared)
                .frame(width: 320)
                .frame(minHeight: 300)
                .frame(maxHeight: 600)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.78).ignoresSafeArea())
                .environmentObject(appState)
                .environmentObject(router)
        } label: {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 20
                $0.size.width = 20 / ratio
                return $0
            }(NSImage(named: "appIcon")!)

            Image(nsImage: image)
                .onAppear {
                    if UserDefaults.standard.bool(forKey: "hasCompletedInitialSetup") == false {
                        openWindow(id: "init")
                    }
                }
                .foregroundColor(.primary)
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $appState.menuBarViewIsPresented)
        .windowResizability(.contentSize)

        WindowGroup("init", id: "init") {
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
        menuBarViewIsPresented = true
    }

    func hideMenu() {
        menuBarViewIsPresented = true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        let POSTHOG_API_KEY = "phc_XZFRnJFd8RVNegex9sLKplgz8KCFxGyLZwxh5usmoig"
        let POSTHOG_HOST = "https://eu.i.posthog.com"

        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)

        PostHogSDK.shared.setup(config)
    }
}
