import SwiftUI

struct SettingsButton: View {
    @State private var settingsHovered: Bool = false
//    @Environment(\.openWindow) var openWindow
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
//                openWindow(id: "app")
            }
            #if targetEnvironment(simulator) || DEBUG
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
}

#Preview {
    SettingsButton()
}
