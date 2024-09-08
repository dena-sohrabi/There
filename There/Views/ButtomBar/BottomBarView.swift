import SwiftUI

extension ContentView {
    struct BottomBarView: View {
        @EnvironmentObject var locationManager: LocationManager

        var body: some View {
            HStack(spacing: 2) {
                AddButton()
                Spacer()

                SettingsButton()
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .overlay(alignment: .top) {
                Divider()
            }
        }
    }

    #Preview {
        BottomBarView()
    }
}
