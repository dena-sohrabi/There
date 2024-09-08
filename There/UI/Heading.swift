import SwiftUI

struct Heading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title)
    }
}

#Preview {
    Heading(title: "Hello, World!")
}
