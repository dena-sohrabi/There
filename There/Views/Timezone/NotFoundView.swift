import SwiftUI

struct NotFoundView: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("😕")
                .font(.largeTitle)
            Text("Entry not found")
                .font(.title)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NotFoundView()
        .frame(width: 320, height: 320)
}
