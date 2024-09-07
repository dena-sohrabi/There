import SwiftUI

struct Heading: View {
    let title: String

    var body: some View {
        Text(title)
            .fontWeight(.semibold)
            .font(.title)
            .padding(.bottom, 18)
    }
}


#Preview {
    Heading(title: "Hello, World!")
}
