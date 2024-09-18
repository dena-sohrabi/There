import SwiftUI

struct BottomBarView: View {
    @Binding var isAtBottom: Bool
    @Binding var sortOrder: SortOrder
    @Binding var showSlider: Bool

    var body: some View {
        HStack(spacing: 2) {
            AddButton()
            Spacer()

            Button {
                withAnimation {
                    showSlider.toggle()
                }
            } label: {
                Image(systemName: "clock.arrow.2.circlepath")
                    .font(.body)
            }
            .buttonStyle(SettingsButtonStyle())
            .help("Time Slider")

            SettingsButton(sortOrder: $sortOrder)
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
    BottomBarView(isAtBottom: .constant(true), sortOrder: .constant(.timeDescending), showSlider: .constant(false))
}
