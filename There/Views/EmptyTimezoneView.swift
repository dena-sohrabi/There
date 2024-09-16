import SwiftUI

struct EmptyTimezoneView: View {
    var body: some View {
        VStack {
            Image("Earth")
                .resizable()
                .frame(width: 158, height: 140)
                .padding(.bottom, 8)
            Text("No Timezones Yet")
                .font(.title)
                .fontWeight(.medium)

            Text("Please Add your first timezones")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EmptyTimezoneView()
        .frame(width: 320, height: 320)
}
