import SwiftUI

struct BottomBarView: View {
    @Binding var isAtBottom: Bool

    var body: some View {
        HStack(spacing: 2) {
            AddButton()
            Spacer()
            SettingsButton()
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 45)
        .overlay(alignment: .top) {
            if isAtBottom {
                Divider()
                    .padding(.top, -2)
            }
        }
        .animation(.default, value: isAtBottom)
    }
}

#Preview {
    BottomBarView(isAtBottom: .constant(true))
}
