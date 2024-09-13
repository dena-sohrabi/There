import SwiftUI

struct SettingsButton: View {
    @State private var settingsHovered: Bool = false
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL
    @EnvironmentObject var appState: AppState
    @Environment(\.database) var database: AppDatabase
    @Environment(\.colorScheme) var scheme

    var backgroundColor: Color {
        if scheme == .dark {
            return Color(.gray).opacity(0.2)
        } else {
            return .white
        }
    }

    var body: some View {
        Menu {
            Button("Open in new Window") {
                appState.hideMenu()
                openWindow(id: "app")
            }
            Section("Support") {
                Button("Support via X") {
                    openURL(URL(string: "https://twitter.com/messages/compose?recipient_id=1434101346110689282")!)
                }
                Button("Support via Email") {
                    openAppleMailComposer(to: "support@there.pm",
                                          subject: "Support Request",
                                          body: "Hello, I need assistance with...")
                }
            }
            Section("Social") {
                Button("Open Website") {
                    openURL(URL(string: "https://there.pm")!)
                }
                Button("Follow on X") {
                    openURL(URL(string: "https://x.com/ThereHQ")!)
                }
            }

            #if targetEnvironment(simulator) || DEBUG
                Section("Dev & Debug") {
                    Button("Clear Cache & Data") {
                        UserDefaults.standard.removeObject(forKey: "hasCompletedInitialSetup")
                        do {
                            _ = try database.dbWriter.write { db in
                                try Entry.deleteAll(db)
                            }
                        } catch {
                            print("Can't clear DB \(error)")
                        }
                    }
                }
            #endif
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.body)
                .foregroundColor(settingsHovered ? .primary : .secondary)
        }
        .onHover { hovering in
            withAnimation {
                settingsHovered = hovering
            }
        }
        .frame(height: 28)
        .padding(.horizontal, 8)
        .background(settingsHovered ? backgroundColor : .clear)
        .cornerRadius(8)
        .buttonStyle(.plain)
    }

    func openAppleMailComposer(to recipient: String, subject: String? = nil, body: String? = nil) {
        let appleMailBundleIdentifier = "com.apple.mail"

        guard let appleMailURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appleMailBundleIdentifier) else {
            print("Apple Mail not found")
            return
        }

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient

        var queryItems = [URLQueryItem]()
        if let subject = subject {
            queryItems.append(URLQueryItem(name: "subject", value: subject))
        }
        if let body = body {
            queryItems.append(URLQueryItem(name: "body", value: body))
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let emailURL = components.url else {
            print("Invalid email URL")
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.open([emailURL], withApplicationAt: appleMailURL, configuration: configuration) { _, error in
            if let error = error {
                print("Failed to open Apple Mail: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    SettingsButton()
}
