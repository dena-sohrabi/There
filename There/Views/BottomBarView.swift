import SwiftUI

struct BottomBarView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        HStack(spacing: 2) {
            AddButton()
            LocationStatusView(cityName: locationManager.cityName)
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
