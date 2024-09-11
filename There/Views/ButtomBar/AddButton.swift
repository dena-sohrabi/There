import SwiftUI

struct AddButton: View {
    @State private var addHovered: Bool = false
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var appState: AppState

    var body: some View {
        CompactButton(title: "Add") {
            appState.menuBarViewIsPresented = false
            appState.hideMenu()
            openWindow(id: "add-timezone")
        }
    }
}

#Preview {
    AddButton()
        .padding()
}
