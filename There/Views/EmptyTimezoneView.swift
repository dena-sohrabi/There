import SwiftUI

struct EmptyTimezoneView: View {
    var body: some View {
        Image("Earth")
            .resizable()
            .frame(width: 80, height: 80)
            .padding(.bottom, 8)
        Text("No Timezones Yet")
            .font(.largeTitle)
            .fontWeight(.semibold)
        Text("Tap \"Add\" to set your first timezone")
            .foregroundColor(.secondary)
    }
}

#Preview {
    EmptyTimezoneView()
}

