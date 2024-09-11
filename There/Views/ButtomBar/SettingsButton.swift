import SwiftUI

struct SettingsButton: View {
    @State private var settingsHovered: Bool = false
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var appState: AppState

    var body: some View {
        Menu {
            Button("Open in new Window") {
                appState.hideMenu()
                openWindow(id: "app")
            }
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
        .background(settingsHovered ? .white : .clear)
        .cornerRadius(8)
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsButton()
}
