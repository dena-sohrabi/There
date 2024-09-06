import SwiftUI
import CoreLocation

struct LocationAccessView: View {
    let authorizationStatus: CLAuthorizationStatus

    var body: some View {
        if authorizationStatus == .notDetermined || authorizationStatus == .denied {
            VStack(alignment: .leading, spacing: 5) {
                Text("Location access is not enabled for this app.")
                    .foregroundColor(.red)
                Text("To enable location access:")
                    .font(.headline)
                Text("1. Open System Preferences")
                Text("2. Go to Security & Privacy")
                Text("3. Select the Privacy tab")
                Text("4. Choose Location Services")
                Text("5. Check the box next to this app's name")

                Button("Open System Preferences") {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!)
                }
                .padding(.top)
            }
        }
    }
}
