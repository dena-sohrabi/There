import SwiftUI

struct Heading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.medium)
    }
}

#Preview {
    Heading(title: "Hello, World!")
}
