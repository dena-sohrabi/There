import SwiftUI

struct AddButton: View {
    @State private var addHovered: Bool = false
    @Environment(\.openWindow) var openWindow

    var body: some View {
        CompactButton(title: "Add") {
            openWindow(id: "add-timezone")
        }
    }
}

#Preview {
    AddButton()
        .padding()
}
