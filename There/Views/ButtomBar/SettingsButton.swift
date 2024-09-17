import SwiftUI

struct SettingsButton: View {
    @State private var settingsHovered: Bool = false
    @Environment(\.openWindow) var openWindow
    @Environment(\.openURL) var openURL
    @EnvironmentObject var appState: AppState
    @Environment(\.database) var database: AppDatabase
    @Environment(\.colorScheme) var scheme
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @Binding var sortOrder: SortOrder
    var backgroundColor: Color {
        if scheme == .dark {
            return Color(.gray).opacity(0.2)
        } else {
            return .white
        }
    }

    var body: some View {
        Menu {
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    if newValue {
                        installLaunchAgent()
                    } else {
                        uninstallLaunchAgent()
                    }
                }
            Toggle("Ascending order", isOn: Binding(
                get: { sortOrder == .timeAscending },
                set: { newValue in
                    sortOrder = newValue ? .timeAscending : .timeDescending
                }
            ))

            Section("Support") {
                Button("DM on X") {
                    openURL(URL(string: "https://twitter.com/messages/compose?recipient_id=1434101346110689282")!)
                }
                Button("Email Us") {
                    openAppleMailComposer(to: "support@there.pm",
                                          subject: "Support Request",
                                          body: "Hello, I need assistance with...")
                }
            }
            Section {
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

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.body)
        }
        .buttonStyle(SettingsButtonStyle())
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
    SettingsButton(sortOrder: .constant(.timeAscending))
}

struct SettingsButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var scheme
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isHovered ? .primary : .secondary)
            .frame(height: 28)
            .padding(.horizontal, 8)
            .background(isHovered ? backgroundColor : .clear)
            .cornerRadius(8)
            .onHover { hovering in
                withAnimation {
                    isHovered = hovering
                }
            }
    }

    private var backgroundColor: Color {
        scheme == .dark ? Color(.gray).opacity(0.2) : .white
    }
}
