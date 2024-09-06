import SwiftUI

struct AddButton: View {
    @State private var addHovered: Bool = false
    @Environment(\.openWindow) var openWindow

    var body: some View {
        Menu {
            Button("Add Person") {
                openWindow(id: "add-person")
            }
            Button("Add Place") {
                openWindow(id: "add-place")
            }
        } label: {
            Text("Add")
                .foregroundColor(addHovered ? .primary : .primary.opacity(0.8))
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .padding(.horizontal, 6)
        .frame(height: 28)
        .background(addHovered ? .white : .white.opacity(0.8))
        .onHover { hovering in
            withAnimation {
                addHovered = hovering
            }
        }
        .cornerRadius(8)
        .shadow(color: .primary.opacity(0.06), radius: 1, x: 0, y: addHovered ? 2 : 1)
    }
}

#Preview {
    AddButton()
        .padding()
}
