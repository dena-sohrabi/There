import SwiftUI

struct SettingsButton: View {
    @Environment(\.openSettings) var openSettings
    @State private var settingsHovered: Bool = false
    @Environment(\.openWindow) var openWindow

    var body: some View {
        Menu {
            Button("Open in new Window") {
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
