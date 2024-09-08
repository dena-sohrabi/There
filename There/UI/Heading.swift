import SwiftUI

struct Heading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
    }
}

#Preview {
    Heading(title: "Hello, World!")
}
