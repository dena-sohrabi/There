import SwiftUI

struct EmptyTimezoneView: View {
    var body: some View {
        VStack {
            Image("Earth")
                .resizable()
                .frame(width: 158, height: 140)
                .padding(.bottom, 8)
                .padding(.leading, -43)
            Text("Hey There!")
                .font(.title)
                .fontWeight(.medium)

            Text("Add your first timezone")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EmptyTimezoneView()
        .frame(width: 320, height: 320)
}
